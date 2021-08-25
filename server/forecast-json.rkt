#lang racket/base

;;  Interface to Forecast via the undocumented web API

(require racket/contract
         racket/port
         racket/string
         json
         gregor
         net/http-client
         net/uri-codec)

(provide
 (contract-out
  (connect               (-> string? string? string? connection?))
  (get-team/json         (-> connection? jsexpr?))
  (get-placeholders/json (-> connection? jsexpr?))
  (get-projects/json     (-> connection? jsexpr?))
  (get-assignments/json  (-> connection? date? date? jsexpr?))
  (get-clients/json      (-> connection? jsexpr?))
  ))

;;; ---------------------------------------------------------------------------------------------------

;; A connection represents an instance of a Forecast server
(struct connection (host acct tokn) #:transparent)

(define (connect host account-id access-token)
  (connection host account-id access-token))

;; Fetch complete tables from the server as JSON

(define (get-team/json conn)
  (get-resource conn "people"))

(define (get-placeholders/json conn)
 (get-resource conn "placeholders"))

(define (get-projects/json conn)
  (get-resource conn "projects"))

(define (get-assignments/json conn start-date end-date)
  ;; Forecast now requires a start and end date when requesting assignments. An assingment is returned
  ;; if it has any overlap with the closed range [start_date, end_date]
  (get-resource
   conn
   "assignments"
   `((start_date . ,(~t start-date "YYYY-MM-dd"))
     (end_date   . ,(~t end-date "YYYY-MM-dd")))))

;; clients : connection? -> json?
(define (get-clients/json conn)
  (get-resource conn "clients"))


;; --------------------------------------------------------------------------------------------------
;; Utilities

;; Request a table from the server 
(define (get-resource conn resource [params #f])
  ;; It's odd we have to build the URL ourselves for http-sendrecv
  (define request
    (if params
        (string-append resource "?" (alist->form-urlencoded params))
        resource))
  
  (define-values (status headers response)
    (http-sendrecv
     (connection-host conn)
     (string-append "/" request) 
     #:ssl? #t
     #:headers (list
                (string-append "Forecast-Account-ID: " (connection-acct conn))
                (string-append "Authorization: Bearer " (connection-tokn conn)))))

  (when (not (http-status-OK? status))
    (let ([error-response (hash-ref (string->jsexpr (port->string response)) 'errors)])
      (raise-user-error "Failed to connect to Forecast\n"
                        (bytes->string/utf-8 status)
                        error-response)))

  ;; Forecast returns a dictionary with a single key, whose value is the table we actually want.
  (let ([response/json (string->jsexpr (port->string response))])
    (hash-ref response/json 
              (string->symbol resource))))


(define (http-status-OK? status)
  (bytes=? status #"HTTP/1.1 200 OK"))


;; --------------------------------------------------------------------------------------------------
;; Notes for developers 

;; A jsexpr is either:
;; - jsnull (which is by default 'null)
;; - boolean?
;; - string?
;; - A number, (or/c exact-integer? (and/c inexact-real? rational?))
;; - [List-of jsexpr?]
;; - [Hash-of (symbol? jsexpr?)] -- which we will re-interpret as a record type
