#lang scribble/manual

@require[
  @for-label[racket/base]
  @for-label["../config.rkt"]
  @for-label["../schedule.rkt"]]

@title{Interface to data held on servers}

@defmodule[whatnow/schedule]{The @racketmodname[whatnow/schedule] library
provides for accessing data from all sources in a consistent way.}

This module defines structures for people, projects, programmes, and
assignments. Not all fields in those structures are provided by all data
sources.

Sources include: Forecast, Harvest, GitHub, and possibly local configuration
files.

The contract for each record mandates that certain core fields are present but
fields that are provided by a specific data source (and may not be available)
are optional.

@defproc[(download-the-schedule) schedule?]{Download project-related data from
all servers and emit consistency warnings.}

@defstruct*[schedule ([people (listof person?)] [projects (listof project?)]
[programmes (listof programme?)] [assignments (listof assignment?)])
#:transparent]{A structure to hold all details of all assignments} 

@defstruct*[person
    ([email           email?]  
     [name            string?]  
     [is-placeholder? boolean?] 
     [forecast-id     (possibly/c forecast-id?)]
     [harvest-id      (possibly/c harvest-id?)]
     [github-id       (possibly/c github-id?)]) #:transparent]{People.}

@defstruct*[project
    ([code                 github-issue?] 
     [name                 string?]      
     [state                (or/c #f
                                 'suggested 'proposal 'project-brief-complete 'with-funder
                                 'finding-resources 'awaiting-start 'active 'completion-review
                                 'done 'cancelled)]
     [programme            (possibly/c github-issue?)] 
     [finance-code         (possibly/c string?)]
     [preferred-start-date (possibly/c date?)]  
     [earliest-start-date  (possibly/c date?)] 
     [latest-end-date      (possibly/c date?)]
     [budget               (possibly/c exact-nonnegative-integer?)] 
     [contacts             (listof string?)]                 
     [forecast-id          (possibly/c forecast-id?)]
     [harvest-id           (possibly/c harvest-id?)]) #:transparent]{Projects.}


@defstruct*[programme
    ([code           github-issue?]   
     [name           string?]         
     [contacts       (listof string?)]
     [forecast-id    (possibly/c forecast-id?)]
     ) #:transparent]{Programmes.}

@defstruct*[assignment
    ([person         email?]
     [project        github-issue?]
     [start-date     date?]
     [end-date       date?]
     [allocation     exact-nonnegative-integer?] 
     ) #:transparent]{Assignments. The @racket[allocation] is in seconds per day.}


