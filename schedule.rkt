#lang racket/base

#|

Wrap all servers to provide a unified interface to all the data, including:

 - people 
 - projects
 - assignments
 - programmes 

Match records referring to the same entity in different systems.

Warnings about inconsistencies are emitted using the whatnow logger

|#

(require racket/contract
         (only-in racket/string string-prefix?))

(require gregor)

(require "config.rkt"
         (prefix-in fc: "server/forecast.rkt")
         "db/types.rkt"
         "logging/logger.rkt"
         )


;; ---------------------------------------------------------------------------------------------------
;; Interface

(provide
 (contract-out 
  (get-the-schedule (-> schedule?))))

;; get-the-schedule : date? date? -> schedule?
;; - Connect to all servers and download all available data. Currently gets assigments which overlap
;; the period of 180 days starting today (due to a Forecast restriction)
;; - Merge
;; - Emit warnings and errors and halt if necessary

(define (get-the-schedule)

  (define the-accounts (config-get-accounts))

  ;; --- Forecast ---

  (define the-forecast-schedule
    (fc:get-the-forecast-schedule (today) (+days (today) 180)))

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



