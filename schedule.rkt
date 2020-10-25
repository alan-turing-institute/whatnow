#lang racket/base

#|

Access to all the data held on backend services, including:

 - people 
 - projects
 - assignments
 - programmes 

This module integrates data from the various backend servers and matches records
from different systems that refer to the same entity

Warnings are emitted using the whatnow logger

|#

(require racket/contract
         (only-in racket/string string-prefix?))

(require "config.rkt"
         "logger.rkt"
         (prefix-in fc: "forecast.rkt")
         )

;; ---------------------------------------------------------------------------------------------------
;; Interface

(provide
 (struct-out schedule)
 get-the-schedule)

(provide
 (all-from-out "forecast.rkt") ;; FIXME -- redefine person, project, &c
 )

(struct schedule
  (people projects programmes assignments)
  #:transparent)

;; get-the-schedule : -> schedule?
;; - Connect to all servers and download all available data
;; - Merge
;; - Emit warnings and errors and halt if necessary
(define (get-the-schedule)
  (define the-accounts (config-get-accounts))

  ;; Forecast 
  (define FORECAST-ACCOUNT (cdr (assoc 'forecast the-accounts)))
  (define <forecast>
    (fc:connect
     (server-account-id FORECAST-ACCOUNT)
     (server-account-token FORECAST-ACCOUNT)))
  (define the-forecast-schedule
    (schedule
     (fc:get-team <forecast>)
     (fc:get-projects <forecast>)
     (fc:get-clients <forecast>)
     (fc:get-assignments <forecast>)))
  (verify-forecast-data the-forecast-schedule)
  the-forecast-schedule)

(define (verify-forecast-data sched)
  (for ([p (in-list (schedule-projects sched))])
    (let ([c (expect-github-issue-code (fc:project-code p))])
      (when (not c)
        (log-message whatnow-logger 'warning 'forecast
                     "Missing or malformed project code in Forecast project:"
                     p)))))

;; expect-github-issue-code : (or/c string? #f) -> (or/c exact-nonnegative-integer? #f)
;; Ensure that a project code looks like a GitHub issue number
;; That is, something that begins hut23-, followed by a number
(define (expect-github-issue-code cd)
  (and cd
       (let ([ps (regexp-match-positions #rx"^hut23-[0-9]+$" cd)])
         (if (or (not ps) (not (null? (cdr ps))))
             #f
             (string->number (substring cd 6))))))
