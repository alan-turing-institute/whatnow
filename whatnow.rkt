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
         "table.rkt")
  (define the-schedule (get-the-schedule))

  (displayln "Successfully obtained")
  (printf " - ~a people;\n" (length (schedule-people the-schedule)))
  (printf " - ~a projects;\n" (length (schedule-projects the-schedule)))
  (printf " - ~a programmes; and\n" (length (schedule-programmes the-schedule)))
  (printf " - ~a assignments\n" (length (schedule-assignments the-schedule)))

  (for ([row (people-table the-schedule (today) (+days (today) 180))])
    (displayln row))
  
  )



#|

People view

(summarise-people-by-week sched date-from date-to)
- sched : schedule?
- date-from : a date?, which is 'rounded down' to the most recent Monday
- date-to : a date?, which is 'rounded up' to the next Sunday.

Produces a week-by-week summary of the staffing level of each person

|#

(require racket/vector
         gregor
         gregor/period)

(require "schedule.rkt"
         "db/types.rkt"
         "table.rkt")


;; people-table : schedule? date? date? -> Table?

;; Number of seconds in five working days
;; (Note that, however, Placeholders assume 7 day weeks)
(define MAX-WEEKLY-EFFORT (* 5 8 60 60))

(define MINOR-VERTICAL-RULE   #\:)
(define MAJOR-VERTICAL-RULE   #\|)
(define MINOR-HORIZONTAL-RULE #\-)
(define MAJOR-HORIZONTAL-RULE #\=)
(define MINOR-VERTICAL-MINOR-HORIZONTAL #\÷)
(define MINOR-VERTICAL-MAJOR-HORIZONTAL #\:)
(define MAJOR-VERTICAL-MINOR-HORIZONTAL #\+)
(define MAJOR-VERTICAL-MAJOR-HORIZONTAL #\=)

;; Naming convention:
;; `person:foo` is a dictionary with person-id as the key and foo as the data

(define (people-table sched date-from date-to)
  (define (person-full-name p)
    (string-append (person-first-name p) " " (person-last-name p)))
  
  ;; weekv : [vector-of date?] (representing weeks by the corresponding Mondays)
  (define weekv         
    (period->weeks date-from date-to)) 

  ;; [hash-of person-id? [vector-of char?]]
  (define person:weekly-effort                  
    (for/hash ([(id efforts) (in-hash (tabulate-people-by-week sched weekv))])
      (values id (vector-map weekly-effort->char efforts))))

  ;; [assoc? person-id? string?]
  (define person:full-name
    (map
     (λ (p) (cons (person-id p) (person-full-name p)))
     (schedule-people sched)))

  (define max-row-header-length
    (apply max (map (λ (p) (string-length (cdr p))) person:full-name)))

  (define max-cols
    (apply max (map vector-length (hash-values person:weekly-effort))))
  
  (define rows
    (map (λ (p) (hash-ref person:weekly-effort (car p) (make-vector max-cols #\space)))
         person:full-name))

  (define (pad-right-or-truncate txt width)
    (let ([txt-width (string-length txt)])
      (cond
        [(< width txt-width) (substring txt 0 width)]
        [(> width txt-width) (string-append txt (make-string (- width txt-width) #\space))]
        [else                txt])))

  ;; hd : row header
  ;; cs : list of column content
  ;; hd-width : width of row header (will be truncated or padded)
  (define (make-row/text hd cs hd-width)
    (string-append
     (pad-right-or-truncate hd hd-width)
     " " (string MAJOR-VERTICAL-RULE) " "
     ((compose list->string vector->list) cs)))
  
  (map (λ (hd cs) (make-row/text hd cs max-row-header-length))
       (map cdr person:full-name) rows)

)



;; numeric? -> char?
(define (weekly-effort->char weekly-effort)
  (let ([rate (/ weekly-effort MAX-WEEKLY-EFFORT)])
    (cond
      [(<  rate 0.05) #\space]
      [(<= rate 0.20) #\.]
      [(<= rate 0.50) #\o]
      [(<= rate 0.80) #\x]
      [(<= rate 0.95) #\O]
      [(=  rate 1.0)  #\X]
      [else           #\#])))


;; Return a map of person-id to a vector of weekly staffing levels (in seconds) for each person-id.
;;
;; schedule? [Vector-of? date?] -> [Hash? person-id? [vector-of number?]]
(define (tabulate-people-by-week sched weekv)

  ;; For each person, add up the weekly staffing levels of all assignments, week by week
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
;; number of non-weekend days in the week overlap the assignment.
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


