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


(module+ main
  (require gregor
         "schedule.rkt"
         mondrian)
  (define *the-schedule* (get-the-schedule))

  (displayln "Successfully obtained")
  (printf " - ~a people;\n" (length (schedule-people *the-schedule*)))
  (printf " - ~a projects;\n" (length (schedule-projects *the-schedule*)))
  (printf " - ~a programmes; and\n" (length (schedule-programmes *the-schedule*)))
  (printf " - ~a assignments\n" (length (schedule-assignments *the-schedule*)))

  (displayln
   (table-pretty-print
    (people-table *the-schedule* (today) (+days (today) 180))
    #:rule-maker (make-standard-rule-maker "=-" "  ")))

  )



#|

People view

Produces a week-by-week summary of the staffing level of each person

|#

(require racket/vector
         racket/list
         gregor
         gregor/period)

(require "schedule.rkt"
         "db/types.rkt"
         mondrian)


;; people-table : schedule? date? date? -> Table?

;; Number of seconds in five working days
;; (Note that, however, Placeholders assume 7 day weeks)
(define MAX-WEEKLY-EFFORT (* 5 8 60 60))
(define MONTH-NAMES #("Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"))

(define (people-table sched date-from date-to)
  (define (person-full-name p)
    (string-append (person-first-name p) " " (person-last-name p)))
  
  ;; weekv : [vector-of date?] (representing weeks by the corresponding Mondays)
  (define weekv         
    (period->weeks date-from date-to)) 

  (define nweeks
    (vector-length weekv))

  ;; Group weeks by "ISO month"
  (define month-groups
    (group-by values (map iso-month-of-date (vector->list weekv)) =))

  (define nweeks-per-month
    (map length month-groups))

  ;; group-by-b : [list-of integer?] [list-of any/c] -> [list-of [list-of any/c]]
  (define (group-by-n ns ws)
    (for/fold ([groups  '()]
               [ws      ws]
               #:result (reverse groups))
              ([n ns])
      (let-values ([(this rest) (split-at ws n)])
        (values (cons this groups) rest))))

  ;; [hash-of person-id? [vector-of char?]]
  (define person:weekly-effort                  
    (for/hash ([(id efforts) (in-hash (tabulate-people-by-week sched weekv))])
      (values id (vector-map weekly-effort->char efforts))))
  
  (define (person-weekly-effort-chars p)
    (map (λ (c) (table-cell (string c)))
         (vector->list
          (hash-ref person:weekly-effort
                    (person-id p)
                    (make-vector nweeks #\∅)))))
  
  (table-col
   (table-row "Person" "Weekly allocation")
   (table-rowwise-bind
    (list
     (table-row "" (table-colwise-bind
                    (map (λ (mg) (table-cell (vector-ref MONTH-NAMES (- (car mg) 1)) #:align 'right))
                         month-groups)))
     (table-rowwise-bind                                           ; Body of table
      (map
       (λ (p)
         (table-row (table-cell (person-full-name p) #:pad? #t)
                    (table-colwise-bind                                  
                     (map table-colwise-bind 
                          ; Group into months
                          (group-by-n nweeks-per-month (person-weekly-effort-chars p))))))
       (schedule-people sched))
      )))))

;; numeric? -> char?
(define (weekly-effort->char weekly-effort)
  (let ([rate (/ weekly-effort MAX-WEEKLY-EFFORT)])
    (cond
      [(<= rate 0.05) #\space]
      [(<= rate 0.20) #\·]
      [(<= rate 0.50) #\›]
      [(<= rate 0.95) #\*]
      [(<= rate 1.0)  #\X]
      [else           #\!])))


;; Return a map of person-id to a vector of weekly staffing levels (in seconds) for each person-id.
;;
;; schedule? [Vector-of? date?] -> [Hash? person-id? [vector-of number?]]
(define (tabulate-people-by-week sched weekv)
  (foldl
   (λ (assgnmnt rates)
     (let ([weekly-rates (weekify-allocation weekv assgnmnt)])
       (hash-update rates
                    (assignment-person-id assgnmnt)
                    (λ (rs) (vector-map + weekly-rates rs))
                    (make-vector (vector-length weekly-rates) 0))))
   (hash)
   (schedule-assignments sched)))


;; Decompose an allocation into weekly totals. The total for a week is the rate multiplied by the
;; number of non-weekend days in the week which overlap the assignment.
;;
;; [Vector-of date?] allocation? -> [Vector-of numeric?]
(define (weekify-allocation weekv a)
  (define r (allocation-rate a))
  (vector-map (λ (week) (* r (weekday-overlap week a))) weekv))


;; How many weekdays in the weeks starting on `dt` (which must be a
;; Monday) are also part of the allocation `a`?
;;
;; date? allocation? -> number?
(define (weekday-overlap dt a)
  (max 0
       (+ 1
          (period-ref
           (date-period-between (date-latest   (allocation-start-date a) dt)
                                (date-earliest (allocation-end-date a) (+days dt 4))
                                '(days))
           'days))))


;; allocation? allocation? -> boolean?
(define (allocation<? alloc1 alloc2)
  (date<? (allocation-end-date alloc1) (allocation-start-date alloc2)))


;; Return a vector of Mondays between date-from and date-to.
;; If date-to is a Monday, that week is not counted.
;;
;; date? date? -> [vector-of date?]
(define (period->weeks date-from date-to)
  (let ([start (most-recent-monday date-from)]) 
    (for/vector ([wk (in-naturals)]
               #:break (date>=? (+weeks start wk) date-to))
      (+weeks start wk))))

;; Return the "ISO month" of the date. The "ISO month" (which is not an official term of ISO 8601)
;; here means "the month in which the Thursday of the week falls."
;; Weeks start on Monday and end on Sunday (as ISO 8601)
;; date? -> [integer-in 1 12]
(define (iso-month-of-date dt)
  (define thursday (+days dt (- 4 (->iso-wday dt))))
  (->month thursday))

(module+ test
  (require rackunit)
  (check-equal? (iso-month-of-date (date 2021 10 1)) 9)
  )

;; Return most recent Monday not later than `dt`
;;
;; date? -> date?
(define (most-recent-monday dt)
  (-days dt (- (->iso-wday dt) 1)))

;; date? date? -> date?
(define (date-earliest dt1 dt2)
  (if (date<? dt1 dt2) dt1 dt2))

;; date? date? -> date?
(define (date-latest dt1 dt2)
  (if (date<? dt1 dt2) dt2 dt1))


(module+ test
  (require rackunit)
  ;; Thursday to Wednesday week
  (define allocn (allocation (date 2021 7 1) (date 2021 7 14) 10))
  (check-equal?
   (weekday-overlap (date 2021 7 5) allocn)
   5)
  (check-equal?
   (weekday-overlap (date 2021 6 28) allocn)
   2)
  (check-equal?
   (weekday-overlap (date 2021 7 12) allocn)
   3)
  (check-equal?
   (weekday-overlap (date 2021 7 19) allocn)
   0)
  (check-equal?
   (weekday-overlap (date 2021 6 21) allocn)
   0)

  (check-equal?
   (weekify-allocation (period->weeks (date 2021 6 28) (date 2021 7 19)) allocn)
   #(20 50 30))


  )


