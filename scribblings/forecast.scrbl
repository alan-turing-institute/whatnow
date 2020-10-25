#lang scribble/manual

@require[
  @for-label[(except-in racket/base date date?)]
  @for-label[gregor]
  @for-label["../forecast.rkt"]]

@title{Structured Interface to the SaaS Servers}

@section{Forecast}

@defmodule[whatnow/forecast]{The @racketmodname[whatnow/forecast] library
provides a wrapper around @racketmodname[whatnow/apis/forecast-json] which
re-exports the downloads as structured data.}

These functions check that all fields are present in the JSON returned from
Forecast; and for some fields a check is made that the field is not-null. An
error is raised if these conditions are not satisfied.

Note that placeholders are not exported, nor is any assignment to a
placeholder. Furthermore, only archived entities are also not returned.

@defproc[(connect [account-id string?] [access-token string?])
                  connection?]{Rexported from @secref["Connecting_to_Forecast"
         #:doc '(lib "whatnow/scribblings/apis.scrbl")]}

@defproc[(get-team [conn connection?])
                   (listof person?)]{
                 Returns the team.}

@defstruct*[person
    ([id         exact-nonnegative-integer?]
     [harvest-id (or/c #f exact-nonnegative-integer?)]
     [first-name (or/c #f string?)]  
     [last-name  (or/c #f string?)]  
     [email      (or/c #f string?)]  
     [login?     boolean?]
     [roles      (listof string?)])
     #:transparent]{
     People.}

@defstruct*[project
    ([id           exact-nonnegative-integer?]
     [harvest-id   (or/c #f exact-nonnegative-integer?)]
     [name         string?]       
     [code         (or/c #f string?)]           
     [tags         (listof string?)]
     [client-id    (or/c #f exact-nonnegative-integer?)])
     #:transparent]{
     Projects.}

@defstruct*[client
    ([id   exact-nonnegative-integer?]
     [name string?])          
     #:transparent]{
     Clients.}

@defstruct*[assignments
    ([person-id  exact-nonnegative-integer?]
     [project-id exact-nonnegative-integer?] 
     [start-date date?]
     [end-date   date?]
     [allocation exact-nonnegative-integer?])
     #:transparent]{
     Assignments. Note that the field @racket[allocation] is in seconds per day.}





