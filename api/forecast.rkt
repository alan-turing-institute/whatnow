#lang racket/base

(require racket/contract
         racket/port
         json
         net/http-client
         )

;;  Interface to Forecast via the undocumented web API

(provide
 (contract-out
  (connect (-> string? string? string? connection?))
  (people  (-> connection? jsexpr?))
  (placeholders (-> connection? jsexpr?))
  (projects  (-> connection? jsexpr?))
  (assignments  (-> connection? jsexpr?))
  (clients  (-> connection? jsexpr?))
  ))

;; A connection represents an instance of a Forecast server
(struct connection (host acct tokn) #:transparent)

(define (connect host account-id access-token)
  (connection host
              account-id
              access-token))

;; Fetch complete tables from the server as JSON

;; people : forecast? -> jsexpr?
(define (people conn)
  (get-and-extract conn "people"))

;; people : forecast? -> jsexpr?
(define (placeholders conn)
 (get-and-extract conn "placeholders"))

;; projects : forecast? -> jsexpr?
(define (projects conn)
  (get-and-extract conn "projects"))

;; schedule : forecast? -> jsexpr?
(define (assignments conn)
  (get-and-extract conn "assignments"))

;; clients : forecast? -> json?
(define (clients conn)
  (get-and-extract conn "clients"))


;; --------------------------------------------------------------------------------------------------
;; Utilities

;; For each resource request, Forecast returns a dictionary with a single key that is the name of the
;; request whose value is the resource actually wanted.
(define (get-and-extract conn request)
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
