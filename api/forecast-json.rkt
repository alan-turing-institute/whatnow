#lang racket/base

;;  Interface to Forecast via the undocumented web API

(require racket/contract
         racket/port
         racket/string
         json
         gregor
         net/http-client
         net/uri-codec
         (only-in "forecast-config.rkt" FORECAST-SERVER))

(provide
 (contract-out
  (connect          (-> string? string? connection?))
  (get-team         (-> connection? jsexpr?))
  (get-placeholders (-> connection? jsexpr?))
  (get-projects     (-> connection? jsexpr?))
  (get-assignments  (-> connection? date? date? jsexpr?))
  (get-clients      (-> connection? jsexpr?))
  ))

;;; ---------------------------------------------------------------------------------------------------

;; A connection represents an instance of a Forecast server
(struct connection (host acct tokn) #:transparent)

(define (connect account-id access-token)
  (connection FORECAST-SERVER account-id access-token))

;; Fetch complete tables from the server as JSON

;; people : connection? -> jsexpr?
(define (get-team conn)
  (get-and-extract conn "people"))

;; placeholders : connection? -> jsexpr?
(define (get-placeholders conn)
 (get-and-extract conn "placeholders"))

;; projects : connection? -> jsexpr?
(define (get-projects conn)
  (get-and-extract conn "projects"))

;; get-assignments : connection? date? date?  -> jsexpr?
(define (get-assignments conn start-date end-date)
  (define assignments-query
    (string-append
     "assignments?"
     (alist->form-urlencoded `((start_date . ,(~t start-date "YYYY-MM-dd"))
                               (end_date . ,(~t end-date "YYYY-MM-dd"))))))
  (get-and-extract conn assignments-query))

;; clients : connection? -> json?
(define (get-clients conn)
  (get-and-extract conn "clients"))


;; --------------------------------------------------------------------------------------------------
;; Utilities

;; Request a table from the server 
(define (get-and-extract conn request)
  ;; Note: Forecast returns a dictionary with a single key.
  ;; The key is the name of the request and the value is the resource actually wanted.
  (hash-ref (get-json-from-endpoint conn request)
            (string->symbol (car (string-split request "?")))))

(define (get-json-from-endpoint conn request)
  (displayln request)
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
  (string->jsexpr (port->string response)))

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
