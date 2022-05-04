#lang racket/base

#|

A wrapper over the Forecast JSON API which re-exports the downloaded records as structs.

The re-exports exclude
- Any archived entity
- "Placeholders" 
- Any Assignment to a Placeholder

There are two checks on records in the JSON data from Forecast:
- all required fields must exist
- selected fields must be non-NULL

|#

(require racket/contract
         racket/string
         (only-in racket/list filter-map)
         gregor)

(require "../db/types.rkt"
         "../config.rkt"
         "forecast-json.rkt")

(provide connect ; Re-exported from forecast-json.rkt
         get-the-forecast-schedule
         get-team
         get-projects
         get-clients
         get-assignments
         get-team/json
         get-projects/json
         get-clients/json
         get-assignments/json
         )

;; ---------------------------------------------------------------------------------------------------

;; get-the-forecast-schedule : date? date? -> schedule?
;; Return a full schedule
;; Makes a call to config-get-accounts
(define (get-the-forecast-schedule start-date end-date)

  ;; There is currently a restriction in Forecast that you can't get more than 180 days'
  ;; worth of allocations
  (when (date>? end-date (+days start-date 180))
    (raise-arguments-error 'get-the-forecast-schedule
                           "Forecast only allows requests for periods no greater than 180 days"
                           "start-date" start-date
                           "end-date" end-date))

  
  (define FORECAST-ACCOUNT
    (cdr (assoc 'forecast (config-get-accounts))))

  (define <forecast>
    (connect
     (server-account-host  FORECAST-ACCOUNT)
     (server-account-id    FORECAST-ACCOUNT)
     (server-account-token FORECAST-ACCOUNT)))

  (schedule
   (get-team <forecast>)
   (get-projects <forecast>)
   (get-clients <forecast>)
   (get-assignments <forecast> (today) (+days (today) 180))))


;; Each `get-` function obtains the corresponding entities from Forecast and checks that certain
;; fields are not null. Archived entities are excluded. 

;; people : connection? -> (listof person?)  
(define (get-team conn)
  (filter-map json->person (get-team/json conn)))

;; projects : connection? -> (listof project?)
(define (get-projects conn)
  (filter-map json->project (get-projects/json conn)))

;; programmes : connection? -> (listof programme?)
(define (get-clients conn)
  (filter-map json->client (get-clients/json conn)))

;; assignments : connection? date? date? -> (listof assignment?)
;; 
;; Returns only assignments to people (ie, excludes assignments to placeholders)
;; Forecast requires end-date - start-date <= 180 days
(define (get-assignments conn start-date end-date)
  (let ([asgns (filter-map json->assignment
                           (get-assignments/json conn start-date end-date))])
    (filter (λ (a) (assignment-person-id a)) asgns)))

;; Return a person? or #f if the person has been archived 
(define (json->person js)
  (and (not (archived? js))
       (person
        [extract/not-null 'id js]
        [extract          'harvest_user_id js]
        [extract          'first_name js] 
        [extract          'last_name js]
        [extract          'email js]
        [equal? (extract  'login js) "enabled"]
        [extract/not-null 'roles js])))

(define (json->project js)
  (and (not (archived? js))
       (project
        [extract/not-null 'id js]
        [extract          'harvest_id  js]
        [extract/not-null 'name js]
        [extract          'code js]
        [extract/not-null 'tags js]
        [extract          'client_id js])))

(define (json->client js)
  (and (not (archived? js))
       (client
        [extract/not-null 'id js]
        [extract/not-null 'name js])))

(define (json->assignment js)
  ;; If person_id is #f, this assignment is to a placeholder
  (and (extract 'person_id js)
       (assignment
        [iso8601->date (extract/not-null 'start_date js)]
        [iso8601->date (extract/not-null 'end_date   js)]
        [extract/not-null 'allocation js]
        [extract          'person_id  js] 
        [extract/not-null 'project_id js]
)))

(define (archived? js)
  (extract 'archived js))


#| 

A note on the shenanigans below.

Forecast allows certain fields to have null values. For example, the `first-name` field of the
`person` record may be empty. In this case, the returned JSON value will be 'null.

The function `extract` sets the field in the corresponding struct is set to #f (the Scheme idiom for
Nothing). The function `extract/not-null` insists that the JSON value is not 'null and will raise an
error if it is.

|#

;; extract/not-null : symbol? jsexpr? -> any/c
(define (extract/not-null key dict)
  (let ([v (hash-ref dict key 'missing)])
    (when (eq? v 'missing)
      (raise-user-error
       (format  "Could not find field ~a in a Forecast record.\n" key)
       dict))
    (when (eq? v 'null)
      (raise-user-error
       (format  "The field '~a' in a Forecast record was null.\n" key)
       dict))
    v))

;; extract : symbol? jsexpr? -> any/c
;; Replaces the json value 'null with #f
(define (extract key dict)
  (let ([v (hash-ref dict key 'missing)])
    (when (eq? v 'missing)
      (raise-user-error
       (format  "Could not find field ~a in a Forecast record.\n" key)
       dict))
    (if (eq? v 'null) #f v)))
