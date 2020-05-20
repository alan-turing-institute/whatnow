#lang racket/base

;; Interface to the Forecast RESTful API
;; https://help.getharvest.com/forecast/faqs/faq-list/api/
;;
;; Forecast does not have a public API, so this interface is based on a combination
;; of guesswork and studying the examples given at the link and also here
;; https://github.com/vafliik/pyforecast

(require racket/contract
         )

;; provides

;; ---------------------------------------------------------------------------------------------------
;; TODO
;; - much of this code is repeated, but must be present at compile-time. Fix this with macros.
;; - email fields should be of type "email"
;; - url fields should be of type "url"



;; ---------------------------------------------------------------------------------------------------
;; Utilities

;; possibly/c : Return a contract that is like C but also accepts null
(define (possibly/c C)
  (or/c 'null C))

;; ---------------------------------------------------------------------------------------------------
;; Types

;; This module defines the following types, reflecting values returned from the API:
;; - project        https://api.forecastapp.com/projects
;; - person         https://api.forecastapp.com/people
;; - assignment     https://api.forecastapp.com/assignments
;; - client         https://api.forecastapp.com/clients

;; The following types are not yet implemented or used
;; - milestone
;; - placeholder
;; - role

(struct project
  (id             ; Forecast project id (not the same as the Harvest id)
   name            
   color          ; Colour of Gantt chart bar on the Forecast web interface
   code           ; By Hut23 convention, `hut23-xxx`, where `xxx` is the GitHub issue number
   notes 
   start_date
   end_date
   harvest_id     ; The id of the linked project in Harvest
   archived       ; Has this project been archived?
   updated_at     
   updated_by_id  ; Person who last updated this contract
   client_id      ; The Forecast client id
   tags           ; By convention, may include Turing Finance codes
   ))

(define project/c
  (struct/c project
            exact-nonnegative-integer?   ; id
            string?                      ; name
            (or/c 'orange 'green 'aqua 'blue 'purple 'magenta 'red 'gray 'black)  ; color
            (possibly/c string?)         ; code
            (possibly/c string?)         ; notes
            date?                        ; start_date
            date?                        ; end_date
            exact-nonnegative-integer?   ; harvest_id
            boolean?                     ; archived
            date?                        ; updated_at
            exact-nonnegative-integer?   ; updated_by_id
            exact-nonnegative-integer?   ; client_id
            (listof string?)             ; tags
            )  
  )

;; jsexpr->project jsexpr? -> project?
(define (jsexpr->project js)
  #f)

(struct person
  (id
   first_name
   last_name
   email
   login
   admin
   archived
   subscribed
   avatar_url
   roles
   updated_at
   updated_by_id
   weekly_capacity   ; in seconds
   working_days      ; true or false for each day of the week, starting Monday
   color_blind        
                     ; personal_feed_token_id -- unused
   ))

(define person/c
  (struct/c person
            exact-nonnegative-integer?  ; id
            string?                     ; first_name
            string?                     ; last_name
            string?                     ; email
            (or/c 'enabled 'disabled)   ; login
            boolean?                    ; admin
            boolean?                    ; archived
            boolean?                    ; subscribed
            string?                     ; avatar_url
            (listof string?)            ; roles
            date?                       ; updated_at
            exact-nonnegative-integer?  ; updated_by_id
            exact-nonnegative-integer?  ; weekly_capacity
            (vectorof boolean? #:immutable #t ) ; working_days
            boolean?                    ; color_blind
            ))

;; jsexpr->person jsexpr? -> person?
(define (jsexpr->person js)
  #f)

(struct assignment
  (id
   start_date
   end_date
   allocation
   notes
   updated_at
   updated_by_id
   project_id
   placeholder_id
   repeated_assignment_set_id
   active_on_days_off
   ))

(define assignment/c
  (struct assignment
    exact-nonnegative-integer? ; id
    date? ; start_date
    date? ; end_date
    ; allocation
    ; notes
    ; updated_at
    ; updated_by_id
    ; project_id
    ; placeholder_id
    ; repeated_assignment_set_id
    ; active_on_days_off
    ))

;; jsexpr->assignment jsexpr? -> assignment?
(define (jsexpr->assignment js)
  #f)

(struct client
  ())

(define client/c
  (struct client
    ))

;; jsexpr->client jsexpr? -> client?
(define (jsexpr->client js)
  #f)


;; (struct milestone
;;   (id
;;    name
;;    date
;;    updated_at
;;    updated_by_id
;;    project_id
;;    ))

;; (struct role
;;   (id
;;    name
;;    placeholder_ids
;;    person_ids
;;    ))

;; (struct placeholder
;;   (id
;;    name
;;    archived
;;    roles
;;    updated_at
;;    updated_by_id))




;; API

;; db instance (using a module as a singleton class)




;; A jsexpr is either:
;; - jsnull (which is by default 'null)
;; - boolean?
;; - string?
;; - A number, (or/c exact-integer? (and/c inexact-real? rational?))
;; - [List-of jsexpr?]
;; - [Hash-of (symbol? jsexpr?)] -- which we will re-interpret as a record type
