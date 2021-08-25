#lang scribble/manual

@require[
  @for-label[(except-in racket/base date date?)]
  @for-label[gregor]
  @for-label["../server/forecast.rkt" "../db/types.rkt"]]

@title{Backends}

@section{Forecast}

@defmodule[whatnow/forecast]{The @racketmodname[whatnow/server/orecast] library
provides a wrapper around @racketmodname[whatnow/server/forecast-json] that
re-exports the downloads as structured data.}

These functions check that all fields are present in the JSON returned from
Forecast; and for some fields a check is made that the field is not-null. An
error is raised if these conditions are not satisfied.

Note that placeholders are not exported, nor is any assignment to a placeholder,
nor are archived entities.

@defproc[(connect [account-id string?] [access-token string?])
                  connection?]{Rexported from @secref["Connecting_to_Forecast"
         #:doc '(lib "whatnow/scribblings/apis.scrbl")]}

@defproc[(get-team [conn connection?])
                   (listof person?)]{

  Returns the team.}

@defproc[(get-projects [conn connection?])
                       (listof project?)]{
                       
  Returns all projects.}

@defproc[(get-clients [conn connection?])
                   (listof person?)]{
                   
  Returns the clients.}

@defproc[(get-assignments [conn connection?])
                   (listof person?)]{

  Returns all assignments.}





