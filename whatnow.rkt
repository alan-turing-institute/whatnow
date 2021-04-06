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

(require (only-in gregor date)
         "schedule.rkt")

(module+ main
  (define the-schedule (get-the-schedule (date 2020 04 01) (date 2020 05 01)))
  (displayln "Successfully obtained")
  (printf " - ~a people;\n" (length (schedule-people the-schedule)))
  (printf " - ~a projects;\n" (length (schedule-projects the-schedule)))
  (printf " - ~a programmes; and\n" (length (schedule-programmes the-schedule)))
  (printf " - ~a assignments\n" (length (schedule-assignments the-schedule))))
