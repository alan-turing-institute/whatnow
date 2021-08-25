#lang racket/base

;; Structures for fundamental entities:
;; - People
;; - Projects and Programmes
;; - Assignments

(require racket/contract)

;; --- Person ---

(struct person
  (email name github-account forecast-id harvest-id roles)
  #:transparent)

(provide
 (contract-out
  (struct person 
    ([email           (or/c #f string?)]  ; Used as key
     [name            (or/c #f string?)]  ; Human-readable name
     [github-account  (or/c #f string?)]
     [forecast-id     (or/c #f exact-nonnegative-integer?)]
     [harvest-id      (or/c #f exact-nonnegative-integer?)]
     [roles           (listof string?)]
     ))))

;; --- Project ---

(struct project
  (code name state
        preferred-start-date earliest-start-date latest-end-date
        budget finance-code
        contacts
        forecast-id harvest-id
        programme-code forecast-programme-id 
)
  #:transparent)

(provide
 (contract-out
  (struct project
    ([code                  exact-nonnegative-integer?] ; The Hut23 project issue number
     [name                  string?]       
     [state                 (or/c #f ; "unknown"
                                  'suggested 'proposal 'project-brief-complete 'with-funder
                                  'finding-resources 'awaiting-start 'active 'completion-review
                                  'done 'cancelled)]
     [preferred-start-date  (or/c #f date?)]  
     [earliest-start-date   (or/c #f date?)] 
     [latest-end-date       (or/c #f date?)]
     [budget                (or/c #f exact-nonnegative-integer?)] ; In FTE-weeks. Note integer!
     [finance-code          (or/c #f string?)]
     [contacts              (listof string?)] ; Email addresses
     [forecast-id           (or/c #f exact-nonnegative-integer?)]
     [harvest-id            (or/c #f exact-nonnegative-integer?)]
     [programme-code        (or/c #f exact-nonnegative-integer?)]  ; A Github issue number
     [forecast-programme-id (or/c #f exact-nonnegative-integer?)] ; Forecast id
     ))))

;; --- Programme ---

(struct programme
  (name forecast-id github-code)
  #:transparent)

(provide
 (contract-out
  (struct programme  
    ([name        string?]          
     [forecast-id (or/c exact-nonnegative-integer?)]
     [github-code (or/c exact-nonnegative-integer?)]))))

;; -- Assignment --

(struct assignment
  (person-email person-forecast-id project start-date end-date allocation)
  #:transparent)

(provide
 (contract-out
  (struct assignment
    ([person-email       (or/c #f string?)]
     [person-forecast-id exact-nonnegative-integer?]
     [project            exact-nonnegative-integer?] ;; Same as project-code
     [start-date         date?]
     [end-date           date?]
     [allocation         exact-nonnegative-integer?] ; Seconds per day
     ))))



