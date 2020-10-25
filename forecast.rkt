#lang racket/base

#|

A wrapper over the Forecast API which re-exports the downloaded records as structs.

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
         gregor
         (prefix-in raw: "api/forecast-json.rkt"))

(provide
 (rename-out [raw:connect connect])
 get-team
 get-projects
 get-clients
 get-assignments
 )

(provide
 (contract-out
  (struct person 
    ([id         exact-nonnegative-integer?]
     [harvest-id (or/c #f exact-nonnegative-integer?)]
     [first-name (or/c #f string?)]  
     [last-name  (or/c #f string?)]  
     [email      (or/c #f string?)]  
     [login?     boolean?]
     [roles      (listof string?)]
     ))))

(provide
 (contract-out
  (struct project
    ([id           exact-nonnegative-integer?]
     [harvest-id   (or/c #f exact-nonnegative-integer?)]
     [name         string?]       
     [code         (or/c #f string?)]           
     [tags         (listof string?)]
     [client-id    (or/c #f exact-nonnegative-integer?)] 
     ))))

(provide
 (contract-out
  (struct client  
    ([id   exact-nonnegative-integer?]
     [name string?]          
     ))))

(provide
 (contract-out
  (struct assignment
    ([person-id  exact-nonnegative-integer?]
     [project-id exact-nonnegative-integer?] 
     [start-date date?]
     [end-date   date?]
     [allocation exact-nonnegative-integer?] ; Seconds per day
     ))))


;; ---------------------------------------------------------------------------------------------------

(struct person
  (id harvest-id first-name last-name email login? roles)
  #:transparent)

(struct project
  (id
   harvest-id
   name
   code
   tags
   client-id)
  #:transparent)

(struct client
  (id name)
  #:transparent)

(struct assignment
  (person-id project-id start-date end-date allocation)
  #:transparent)


;; ---------------------------------------------------------------------------------------------------

;; Each function obtains the corresponding entities from Forecast and checks for consistency with
;; certain integrity constraints. It is considered a fatal error if any of these checks fail to
;; pass. They are as follows:


;; people : connection? -> (listof person/forecast?)  
(define (get-team conn)
  (let ([ppl (filter-map json->person (raw:get-team conn))])
    ppl))

;; projects : connection? -> (listof project/forecast?)
(define (get-projects conn)
  (let ([prjs (filter-map json->project (raw:get-projects conn))])
    prjs))

;; programmes : connection? -> (listof programme/forecast?)
(define (get-clients conn)
  (let ([pgms (filter-map json->client (raw:get-clients conn))])
    pgms))

;; assignments : connection? -> (listof assignment?)
;; Return only assignments to people (exclude assingments to placeholders) 
(define (get-assignments conn)
  (let ([asgns (filter-map json->assignment (raw:get-assignments conn))])
    (filter (λ (a) (assignment-person-id a)) asgns)))

;; json->person : jsepxr? -> person?
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
  (let ([a (assignment
            [extract          'person_id  js] ; If #f, this assignment is to a placeholder
            [extract/not-null 'project_id js]
            [iso8601->date (extract/not-null 'start_date js)]
            [iso8601->date (extract/not-null 'end_date   js)]
            [extract/not-null 'allocation js])])
    (and (assignment-person-id a)
         a)))

(define (archived? js)
  (extract 'archived js))


#| 

A note on the shenanigans below.

The json library represents JSON `null` as the symbol 'null. Typically, this means that the value
is missing. In some cases a missing value is permitted in a Forecast record returned by this
module, and in those cases the missing is represented by the value #f. In other cases a missing
value is not allowed (and an error is raised here). However, sometimes the type of the value is
boolean? and in those cases, although a missing is not allowed, a value of #f is perfectly
reasonable.

|#

;; extract : symbol? jsexpr? -> any/c
;; Extract a value from a jsexpr dictionary given the key. Halt with an error if the field is not
;; present or if the value is #f.
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
;; Extract a value from a jsexpr dictionary given the key. Halt with an error if the field is not
;; present. If the value is 'null, replace it with #f
(define (extract key dict)
  (let ([v (hash-ref dict key 'missing)])
    (when (eq? v 'missing)
      (raise-user-error
       (format  "Could not find field ~a in a Forecast record.\n" key)
       dict))
    (if (eq? v 'null) #f v)))
