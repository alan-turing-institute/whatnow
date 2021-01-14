#lang racket/base

;;  Interface to Forecast via the undocumented web API

(require racket/contract
         racket/port
         json
         net/http-client
         (only-in "forecast-config.rkt" FORECAST-SERVER))

(provide
 (contract-out
  (connect      (-> string? string? connection?))
  (get-team         (-> connection? jsexpr?))
  (get-placeholders (-> connection? jsexpr?))
  (get-projects     (-> connection? jsexpr?))
  (get-assignments  (-> connection? jsexpr?))
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

;; schedule : connection? -> jsexpr?
(define (get-assignments conn)
  (get-and-extract conn "assignments"))

;; clients : connection? -> json?
(define (get-clients conn)
  (get-and-extract conn "clients"))


;; --------------------------------------------------------------------------------------------------
;; Utilities

;; Request a table from the server 
(define (get-and-extract conn request)
  ;; Note: Forecast returns a dictionary with a single key.
  ;; The key is the name of the request and the value is the resource actually wanted.
  (hash-ref (get-json-from-endpoint conn request) (string->symbol request)))

(define (get-json-from-endpoint conn request)
  (define-values (status headers response)
    (http-sendrecv
     (connection-host conn)
     (string-append "/" request)
     #:ssl? #t
     #:headers (list
                (string-append "Forecast-Account-ID: " (connection-acct conn))
                (string-append "Authorization: Bearer " (connection-tokn conn)))))
  (when (not (http-status-OK? status))
    (raise-user-error "Failed to connect to Forecast" status))
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
