#lang racket/base

#|

Declarations for record types representing "real-world" data:

- schedule
 - person
 - project
 - client
 - assignment
 - TODO: resource

|#

(require racket/contract
         gregor)

(provide
 (contract-out
  (struct schedule
    ([people      (listof person?)]
     [projects    (listof project?)]
     [programmes  (listof client?)]
     [assignments (listof assignment?)]))))

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
     ))

  (struct project
    ([id           exact-nonnegative-integer?]
     [harvest-id   (or/c #f exact-nonnegative-integer?)]
     [name         string?]       
     [code         (or/c #f string?)]           
     [tags         (listof string?)]
     [client-id    (or/c #f exact-nonnegative-integer?)] 
     ))

  (struct client  
    ([id   exact-nonnegative-integer?]
     [name string?]          
     ))

  (struct assignment
    ([start-date date?] ; Assignments are closed intervals 
     [end-date   date?] ; ie, start and end dates are inclusive
     [rate       exact-nonnegative-integer?] ; Seconds per day
     [person-id  exact-nonnegative-integer?]
     [project-id exact-nonnegative-integer?]))

  (struct allocation
    ([start-date date?]
     [end-date   date?]
     [rate       exact-nonnegative-integer?]))
  ))


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

(struct allocation
  (start-date end-date rate)
  #:transparent)

(struct assignment allocation
  (person-id project-id)
  #:transparent)

(struct schedule
  (people projects programmes assignments)
  #:transparent)

