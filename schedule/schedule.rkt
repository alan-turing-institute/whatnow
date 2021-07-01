#lang racket/base

#|

Wraps all servers to provide a unified interface to all the data held on backend services, including:

 - people 
 - projects
 - assignments
 - programmes 

Integrates data from the various backend servers and matches records referring to the same entity in
different systems.

Warnings about inconsistencies are emitted using the whatnow logger

|#

(require racket/contract
         (only-in racket/string string-prefix?))

(require gregor)

(require "../servers/config.rkt"
         (prefix-in fc: "../servers/forecast.rkt")
         "../db/types.rkt"
         "../logging/logger.rkt"
         )


;; ---------------------------------------------------------------------------------------------------
;; Interface

(provide
 (contract-out 
  (struct schedule
    ([people      (listof person?)]
     [projects    (listof project?)]
     [programmes  (listof client?)]
     [assignments (listof assignment?)]))
  (get-the-schedule (-> schedule?))))

(struct schedule
  (people projects programmes assignments)
  #:transparent)

;; get-the-schedule : date? date? -> schedule?
;; - Connect to all servers and download all available data, with assignments
;;   between start-date and end-date (see the note on `get-assigments`)
;; - Merge
;; - Emit warnings and errors and halt if necessary
(define (get-the-schedule start-date end-date)

  (define the-accounts (config-get-accounts))

  ;; --- Forecast ---

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
     (fc:get-assignments <forecast> start-date end-date)))

  (verify-forecast-data the-forecast-schedule)

  the-forecast-schedule)

(define (verify-forecast-data sched)
  (for ([p (in-list (schedule-projects sched))])
    (let ([c (expect-github-issue-code (project-code p))])
      (when (not c)
        (log-message whatnow-logger 'warning 'forecast
                     "Missing or malformed project code in Forecast project"
                     p)))))

;; expect-github-issue-code : (or/c string? #f) -> (or/c exact-nonnegative-integer? #f)
;; Ensure that a project code looks like a GitHub issue number
;; That is, something that begins hut23-, followed by a number
(define (expect-github-issue-code cd)
  (and cd
       (let ([ps (regexp-match #rx"^hut23-[0-9]+$" cd)])
         (if (or (not ps) (not (null? (cdr ps))))
             #f
             (string->number (substring cd 6))))))


;; ---------------------------------------------------------------------------------------------------
;; Utility functions for dealing with schedules



