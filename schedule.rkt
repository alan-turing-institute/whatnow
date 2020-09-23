#lang racket/base

;; Access to all the data held on backend services, including
;; - people (including non-persons, eg, placeholders)
;; - projects
;; - assigments
;; - programmes

;; This module integrates data from the various backend services (removing unused data) and matches
;; records from different systems that refer to the same entity

(require racket/contract
         "config.rkt"
         (prefix-in forecast- "api/forecast.rkt"))

;; ---------------------------------------------------------------------------------------------------
;; Interface

(provide
 (struct-out schedule)
 download-the-schedule
 )

(provide
 (contract-out
  (struct person 
    ([email           email?]   ; Used as key
     [name            string?]  ; Human-readable name
     [is-placeholder? boolean?] ; #t if this "person" is a placeholder 
     [forecast-id     (possibly/c forecast-id?)]
     [harvest-id      (possibly/c harvest-id?)]
     [github-id       (possibly/c github-id?)]
     ))))

(provide
 (contract-out
  (struct project
    ([code                 github-issue?] ; The Hut23 project issue number, used as a key
     [name                 string?]       ; Human-readable string
     [state                (or/c #f
                                 'suggested 'proposal 'project-brief-complete 'with-funder
                                 'finding-resources 'awaiting-start 'active 'completion-review
                                 'done 'cancelled)]
     [programme            (possibly/c github-issue?)] ; Programme /service area issue number
     [finance-code         (possibly/c string?)]
     [preferred-start-date (possibly/c date?)]  
     [earliest-start-date  (possibly/c date?)] 
     [latest-end-date      (possibly/c date?)]
     [budget               (possibly/c exact-nonnegative-integer?)] ; In FTE-weeks. Note integer!
     [contacts             (listof string?)]                  ; TODO. Should be person.
     [forecast-id          (possibly/c forecast-id?)]
     [harvest-id           (possibly/c harvest-id?)]
     ))))


(provide
 (contract-out
  (struct programme
    ([code           github-issue?]    ; The GitHub issue for this group
     [name           string?]          ; Human-readable string
     [contacts       (listof string?)] ; TODO
     [forecast-id    (possibly/c forecast-id?)]
     ))))


(provide
 (contract-out
  (struct assignment
    ([person         email?]
     [project        github-issue?]
     [start-date     date?]
     [end-date       date?]
     [allocation     exact-nonnegative-integer?] ; Seconds per day
     ))))

;; ---------------------------------------------------------------------------------------------------
;; Structures

(struct schedule (people projects programmes assignments) #:transparent)

(struct person
  (email name is-placeholder? forecast-id harvest-id github-id)
  #:transparent)

(struct project
  (code name state programme finance-code
        preferred-start-date earliest-start-date latest-end-date
        budget contacts forecast-id harvest-id)
  #:transparent)

(struct programme
  (code name contacts forecast-id)
  #:transparent)

(struct assignment
  (person project start-date end-date allocation)
  #:transparent)

;; ---------------------------------------------------------------------------------------------------
;; Parameters

;; ---------------------------------------------------------------------------------------------------
;; Contracts

(define (possibly/c C)
  (or/c #f C))

(define forecast-id?  exact-nonnegative-integer?)
(define harvest-id?   exact-nonnegative-integer?)
(define github-id?    string?)
(define github-issue? exact-nonnegative-integer?)
(define email?        string?)

;; ---------------------------------------------------------------------------------------------------


;; download-the-schedule : -> schedule?
;; Connect to all servers, download all available data, emit consistency warnings

(define (download-the-schedule)
  (define accounts (config-get-accounts))
  (define FORECAST-ACCOUNT (cdr (assoc 'forecast accounts)))
  (define forecast-connection
    (forecast-connect
     (server-account-id FORECAST-ACCOUNT)
     (server-account-token FORECAST-ACCOUNT)))
  (schedule
   (forecast-people forecast-connection)
   (forecast-projects forecast-connection)
   (forecast-clients forecast-connection)
   (forecast-assignments forecast-connection)))
