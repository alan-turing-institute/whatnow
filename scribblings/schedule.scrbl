#lang scribble/manual

@require[
  @for-label[racket/base]
  @for-label["../config.rkt"]
  @for-label["../schedule.rkt"]]

@title{The current schedule}

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

@defproc[(get-the-schedule) schedule?]{Download project-related data from
all servers and emit consistency warnings.}

@defstruct*[schedule ([people (listof person?)]
                      [projects (listof project?)]
                      [programmes (listof programme?)]
                      [assignments (listof assignment?)])
                      #:transparent]{

        A structure to hold all details of all assignments. FIXME: At the
        moment, the structure definitions from @racketmodname[whatnow/forecast]
        are simply re-exported.}
        
@section[#:tag "assignables"]{Persons and placeholders}

Only one kind of entity can actually undertake a project: a person. However,
@emph{two} kinds of entity may be assigned to projects in Forecast: real people
and ``placeholders.'' A placeholder is a stand-in for a final
assignment of a person. It has a duration and a rate, just like a normal
assignment. Whatnow does not report on or manage placeholders.

We use placeholders for two different reasons. First, to indicate that some
individual from a particular group will eventually be assigned; we just don't
yet know which individual. We use this kind of placeholder mainly for
assignments from our partner RSE teams. And second, to server as a marker that a
project exists and that we will need to assign someone but have not yet done
so. We introduced this kind of placeholder to aid with tracking of projects,
both manually and by means of the Wimbledon Planner. Without this kind of
placeholder a project would not show up in the Forecast schedule and we would
not know that there was a pending assignment to resolve.

Our intent is to avoid at least the second kind of placeholder in
future. ``Unstaffed'' projects can be discovered by comparing the overall
project details from GitHub with the assignments on Forecast and this is what
Whatnow will do.



