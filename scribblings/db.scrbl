#lang scribble/manual

@require[
  @for-label[(except-in racket/base date date?)]
  @for-label[gregor]
  @for-label["../db/db.rkt"]]

@title{Data types and utilities}

@defmodule[whatnow/db]{@racketmodname[whatnow/db] defines the representation of
people, projects, assignments, and so forth, together with utilities for these
types.}

@defstruct*[schedule ([people (listof person?)]
                      [projects (listof project?)]
                      [programmes (listof programme?)]
                      [assignments (listof assignment?)])
                      #:transparent]{

        A structure to hold all details of all assignments.}

@defstruct*[person
    ([id         exact-nonnegative-integer?]
     [harvest-id (or/c #f exact-nonnegative-integer?)]
     [first-name (or/c #f string?)]  
     [last-name  (or/c #f string?)]  
     [email      (or/c #f string?)]  
     [login?     boolean?]
     [roles      (listof string?)])
     #:transparent]{
     
     A member of the team who can be assigned to a Project. Persons are
     individuated by a Forecast identifier, @racket[id]. Forecast is
     authoritative for persons and the fields @racket[login?] and @racket[roles]
     hold Forecast-specific data. We don't have emails for every person because
     some people work for our partner university RSE teams.}

@defstruct*[project
    ([id           exact-nonnegative-integer?]
     [harvest-id   (or/c #f exact-nonnegative-integer?)]
     [name         string?]       
     [code         (or/c #f string?)]           
     [tags         (listof string?)]
     [client-id    (or/c #f exact-nonnegative-integer?)])
     #:transparent]{

     A project. The GitHub project tracker is authoritative for projects and
     @racket[id] is the GitHub issue number of the project. (It is an error if a
     project on Forecast does not have an issue number.)}

@defstruct*[client
    ([id   exact-nonnegative-integer?]
     [name string?])          
     #:transparent]{
     Clients.}

@defstruct*[allocation
    ([start-date date?]
     [end-date   date?]
     [rate exact-nonnegative-integer?])
     #:transparent]{
     
     An allocation of a resource. Note that the units of @racket[allocation] are
     seconds per day. We generally align assignments so that @racket[start-date]
     falls on a Monday and @racket[end-date] on a Sunday but this is not
     guaranteed.}

@defstruct*[assignment
    ([person-id  exact-nonnegative-integer?]
     [project-id exact-nonnegative-integer?] 
     [start-date date?]
     [end-date   date?]
     [allocation exact-nonnegative-integer?])
     #:transparent]{
     
     Assignments. Note that the units of @racket[allocation] are seconds per
     day. We generally align assignments so that @racket[start-date] falls on a
     Monday and @racket[end-date] on a Sunday but this is not guaranteed.}

@defproc[(allocation<? [alloc1 allocation?] [alloc2 allocation?]) boolean?]{
  @racket[(allocation<? alloc1 alloc2)] is @racket[#t] if @racket[alloc2]
  strictly precedes @racket[alloc2] in time.}

