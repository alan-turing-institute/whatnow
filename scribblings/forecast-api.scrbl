#lang scribble/base

@title{A guide to the Forecast API}

@hyperlink["https://forecastapp.com"]{Forecast} is our SaaS system for recording
project assignments. It contains three primary kinds of entity: @emph{person},
representing a member of the REG team, typically also having an account on the
system and an email address; @emph{project}, something to which we assign
people; and @emph{assignment}, a contiguous range of days for which a person is
assigned to a project. With very few exceptions a project is individuated by a
GitHub issue id. The exceptions are certain `global' projects, which we use to
manage availability. It is sometimes useful to know the @emph{Client}, which we
use in practice to record the Programme.

As of the time of writing, Forecast does not have an official API. However,
there is an undocumented REST endpoint and there are libraries written against
this endpoint in
@hyperlink["https://www.npmjs.com/package/forecast-promise"]{Node.js},
@hyperlink["https://github.com/joefitzgerald/forecast"]{Go}, and
@hyperlink["https://github.com/xvilo/harvest-forecast"]{PHP}. The rest of this
note tries to document the undocumented API.


@section{Requests}

In general, a request is a GET request to the appropriate resource, including
the request headers @tt{Forecast-Account-ID} (which should contain the
identifier for the team's account) and @tt{Authorization} which should be a
bearer token obtained from Forecast. (That is, it is the string
@tt{Bearer}, followed by a space, followed by the bearer token.)

@subsection{Endpoint}

The endpoint is:

@centered[@verbatim{https://api.forecastapp.com/}]

@subsection{Authentication}

To authenticate, obtain a ``Personal Access Token'' from the developers section
of Harvest: @url{https://id.getharvest.com/developers}. This needs to be passed
as a bearer token for every request.

@section{Resources}

A GET request to a resource produces a JSON object. Here we document only the
following resources:

@tabular[#:sep @hspace[1]
   (list
    (list "Project"  @tt{https://api.forecastapp.com/projects})
    (list "Persons"  @tt{https://api.forecastapp.com/people})
    (list "NPCs"     @tt{https://api.forecastapp.com/placeholders})
    (list "Schedule" @tt{https://api.forecastapp.com/assignments})
    (list "Clients"  @tt{https://api.forecasptapp.com/clients}))]

All of this documentation was produced by making the GET request and inspecting
the output; the actual API, being undocumented, could of course change at any
time.

@subsection{Projects}

A GET request to the @tt{projects} resource returns a dictionary with the single
key, @tt{projects}. The value associated with this key is an array of
@emph{project}. A @emph{project} is a dictionary with the following fields:

@tabular[#:sep @hspace[1] #:row-properties '(bottom-border ())
                          #:column-properties '(() () right)
  (list
    (list "Key"              "JSON type of value" "Example")
    (list @tt{id}            @elem{@italic{numeric} (integer)} "1824209")
    (list @tt{harvest_id}    @elem{@italic{numeric} (integer)} "19058649")
    (list @tt{client_id}     @elem{@italic{numeric} (integer)} "781285")
    (list @tt{name}          @italic{string}          "Nocell - Phase 1")
    (list @tt{code}          @italic{string}          "hut23-266")
    (list @tt{start_date}    @italic{string}          "2018-11-01")
    (list @tt{end_date}      @italic{string}          "2019-05-31")
    (list @tt{tags}          @elem{@italic{array} of @italic{string}} "GitHub:266, R-SPET-103")
    (list @tt{color}         @italic{string}          "orange")
    (list @tt{notes}         @italic{string}          @tt{null})
    (list @tt{archived}      @italic{boolean}         @tt{false})
    (list @tt{updated_at}    @elem{@italic{string} (timestamp)} "")
    (list @tt{updated_by_id} @elem{@italic{numeric} (integer)} ""))]

Most of these fields are self-explanatory (or anyway we have guessed
them). Harvest has its own database of projects---even though they are the same
users---and @tt{harvest_id} connects the project on Forecast with the same
project on Harvest. The @tt{client_id} refers to the @emph{client}, a grouping
of projects (which we use to identify the Programme). We use the @tt{code} to
store the GitHub issue number: all projects must have an issue number although
of course this is not enforced by Forecast. The @tt{tags} are a list of
user-assigned tags, which we use in particular to store the `Finance project
code' when we know it. (It is identified only by being of this particular form
as other tags may be present in the list.) We occasionally use the @tt{notes}
field to store a link to the issue on GitHub. 


@subsection{Persons}

A GET request to the @tt{people} resource returns a dictionary with the single
key, @tt{people}. The value associated with this key is an array of
@tt{person}. A @tt{person} is a dictionary with the following fields:

@tabular[#:sep @hspace[1] #:row-properties '(bottom-border ())
                          #:column-properties '(() () right)
  (list
    (list "Key"                "JSON type of value"   "Example")
    (list @tt{id}              @elem{@italic{numeric} (integer)} "")
    (list @tt{harvest_user_id} @elem{@italic{numeric} (integer)} "")
    (list @tt{first_name}      @italic{string}        "James")
    (list @tt{last_name}       @italic{string}        "Geddes")
    (list @tt{email}           @italic{string}        "jgeddes@turing.ac.uk")
    (list @tt{avatar_url}      @italic{string}        "")
    (list @tt{login}           @italic{string}        "enabled")
    (list @tt{admin}           @italic{boolean}       "")
    (list @tt{archived}        @italic{boolean}       "")
    (list @tt{color_blind}     @italic{boolean}       "")
    (list @tt{roles}           @elem{@italic{array} of @italic{string}} "")
    (list @tt{weekly_capacity} @elem{@italic{numeric} (integer)} "144000")          
    (list @tt{working_days}    @elem{@italic{dict} of @italic{boolean}} "")
    (list @tt{personal_feed_token_id} "?"             @tt{null})
    (list @tt{subscribed}      @italic{boolean}       "")
    (list @tt{updated_at}      @elem{@italic{string} (timestamp)} "2020-04-08T13:46:01.840Z")
    (list @tt{updated_by_id}   @elem{@italic{numeric} (integer)} ""))]

The following fields may not be obvious. Harvest has its own database of
users---even though they are the same users---and @tt{harvest_user_id} connects
the user on Forecast with their dopplegänger on Harvest. The elements of the
array in @tt{roles} are user-defined strings (such as ``REG Permanent'') that
are listed in the resource @tt{roles} (although, oddly, they are given here as
their descriptions, rather than their ids in that resource). The weekly
availabilty @tt{weekly_capacity} is given in seconds. The keys of the dictionary
@tt{working_days} are "monday", "tuesday", and so on, and the values are
boolean.

The meanings of @tt{login}, @tt{personal_feed_token_id}, and
@tt{subscribed} are unknown.


@subsection{Assignments}

A GET request to the @tt{assignments} resource returns a dictionary with the
single key, @tt{assignments}. The value associated with this key is an array of
@emph{assignment}. An @emph{assignment} is a dictionary with the following
fields:

@tabular[#:sep @hspace[1] #:row-properties '(bottom-border ())
                          #:column-properties '(() () right)
  (list
    (list "Key"              "JSON type of value" "Example")
    (list @tt{id}             @elem{@italic{numeric} (integer)} "19858217")
    (list @tt{project_id}     @elem{@italic{numeric} (integer)} "1824209")
    (list @tt{person_id}      @elem{@italic{numeric} (integer)} "399979")
    (list @tt{placeholder_id} @elem{@italic{numeric} (integer)} @tt{null})
    (list @tt{start_date}     @italic{string}                   "2019-01-01")
    (list @tt{end_date}       @italic{string}                   "2019-05-31")
    (list @tt{allocation}     @elem{@italic{numeric} (integer)} "14400")
    (list @tt{notes}          @italic{string}                   "Assuming allocation approved.")
    (list @tt{repeated_assignment_set_id} @elem{@italic{numeric} (integer)} @tt{null})
    (list @tt{active_on_days_off} @italic{boolean}               @tt{false})
    (list @tt{updated_at}     @elem{@italic{string} (timestamp)} "2019-03-12T16:28:59.727Z")
    (list @tt{updated_by_id}  @elem{@italic{numeric} (integer)} "408182"))]
    

@tt{project_id} and @tt{person_id} identify the @emph{project} and @emph{person}
respectively. A @tt{placholder_id} identifies a @emph{placeholder}, which is a
Forecast entity that serves to allocate time with allocating an individual. We
use placeholders to reserve time for partners (where we don't know the
particular individual) or to indicate that some resource is required at a
certain time.

The @tt{allocation} is the time, in seconds per day, allocated to this project
each working day of the assignment. Since we use a nominal eight-hour day, an
@tt{allocation} of 14,400 indicates a 50% allocation.

Forecast allows one to create an assignment that is for specific days of the
week, repeated for a certain number of weeks. The
@tt{repeated_assignment_set_id} is (presumably) a link to a separate record that
indicates which days of the week and for how long. We do not use this feature.

Finally, @tt{active_on_days_off} is a flag to indicate whether this assignment
includes, for example, weekends. We do not use this feature, either.


@subsection{Clients}

A GET request to the @tt{clients} resource returns a dictionary with the single
key, @tt{clients}. The value associated with this key is an array of
@emph{client}. A @emph{client} is a dictionary with the following fields:

@tabular[#:sep @hspace[1] #:row-properties '(bottom-border ())
                          #:column-properties '(() () right)
  (list
    (list "Key"              "JSON type of value" "Example")
    (list @tt{id}            @elem{@italic{numeric} (integer)} "769467")
    (list @tt{name}          @italic{string}          "Health")      
    (list @tt{harvest_id}    @elem{@italic{numeric} (integer)} "7394382")
    (list @tt{archived}      @italic{boolean}         @tt{false})
    (list @tt{updated_at}    @elem{@italic{string} (timestamp)} "")
    (list @tt{updated_by_id} @elem{@italic{numeric} (integer)} "399979"))]

