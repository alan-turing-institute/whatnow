#lang racket/base

#|

Whatnow -- reports

TODO:

1. 12 months ahead, monthly, by project
   - fully resourced / partially resourced / not resourced
   - staffing level (?, ., o, O, *, X)

2. 2 months ahead, weekly, by project

3. Same, for people

|#

(require "schedule.rkt"
         gregor)

(module+ main
  (define the-schedule (get-the-schedule))
  (displayln "Successfully obtained")
  (printf " - ~a people;\n" (length (schedule-people the-schedule)))
  (printf " - ~a projects;\n" (length (schedule-projects the-schedule)))
  (printf " - ~a programmes; and\n" (length (schedule-programmes the-schedule)))
  (printf " - ~a assignments\n" (length (schedule-assignments the-schedule))))


#|

People view

(summarise-people-by-week sched date-from date-to)
- sched : schedule?
- date-from : a date?, which is 'rounded down' to the most recent Monday
- date-to : a date?, which is 'rounded up' to the next Sunday.

Produces a week-by-week summary of the staffing level of each person

|#

;; summarise-people-by-week : schedule? date? date?
;; -> [assoc person? [assoc date? number?]]   
(define (summarise-people-by-week sched date-from date-to)
  (define weeks (period-by-week date-from date-to))
  #f
  )

