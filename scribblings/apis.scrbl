#lang scribble/manual

@require[
  @for-label[racket/base]
  @for-label[json]
  @for-label[whatnow/server/forecast-json]]

@title{API documentation}

@section{Forecast} @defmodule[whatnow/api/forecast-json]{The
@racketmodname[whatnow/api/forecast-json] library provides procedures for
accessing the data stored on Forecast.}

@hyperlink["https://forecastapp.com"]{Forecast} is our SaaS system for recording
current and future project assignments. We typically ``bill'' projects based on
the allocations in Forecast. Forecast manages five primary kinds of entity
(along with some others that are not exposed by this interface):

@itemlist[#:style 'ordered

  @item{@deftech{Person}

        A person represents an individual who is able to be assigned to
        projects. Such an individual will have an account on Forecast and an
        email address.}

  @item{@deftech{Placeholder}

        A placeholder is an entity that is treated like a @tech{person} for the
        purpose of assignments to @tech{projects} but which does not represent
        an individual in the real world. We use placeholders to hold project
        @tech{assignments} where we have not yet decided on the individual to be
        assigned; as well as @tech{assignments} representing a number of
        possible individuals, such as those from a particular partner, where,
        again, we are not sure who it will be.

        Forecast provides placeholders in addition to persons because it bills
        us based on the number of persons. However, it also restricts the number
        of @tech{placeholders} to be a fraction of the number of @tech{persons},
        as well as the total assignments to a specific placeholder.}

  @item{@deftech{Project}

        A project corresponding to a unique GitHub issue on the Project Tracker.}

  @item{@deftech{Client}

        A single level grouping of @tech{projects}. We use clients mainly to
        correspond to Turing Programmes.}

  @item{@deftech{Assignment}

        A contiguous range of days for which a @tech{person} is assigned to a
        @tech{project}.}

]

With very few exceptions a project is individuated by a GitHub issue number. The
exceptions are certain `global' projects, which we use to manage
availability. 

As of the time of writing, Forecast does not have an official API. However,
there is an undocumented REST endpoint and there are libraries written against
this endpoint in
@hyperlink["https://www.npmjs.com/package/forecast-promise"]{Node.js},
@hyperlink["https://github.com/joefitzgerald/forecast"]{Go}, and
@hyperlink["https://github.com/xvilo/harvest-forecast"]{PHP}. The rest of this
note tries to document the undocumented API.

@subsection{Connecting to Forecast}

@defproc[(connect [host string?] [account-id string?] [access-token string?])
         connection?]{
         Returns a structure representing a connnection
         to the Forecast server, given the appropriate authentication details.}

The account id is most easily found by logging in via the web interface and
reading the number that appears in the URL just after the server name. To obtain
an authentication token you will need to log in to @emph{Harvest} and look for
the ``Developers'' section, within which there will be an option to obtain a
``Personal Access Token.'' @margin-note{The Forecast server's URL is hardcoded
(in @racketmodname["whatnow/api/local-config.rkt"]) as
@url{https://api.forecastapp.com}}

Now obtain a connection with a call to @racket[connect] and use one of request
forms described in @secref{requests}.

@subsection[#:tag "requests"]{Requesting data from Forecast}


@; --- People

@defproc[(get-people [conn connection?])
                        jsexpr?]{
                 Returns a @tech[#:doc '(lib "json/json.scrbl")]{jsexpr}
                 containing details of all @tech{persons}.}

The return value is a list of people. Each person is a dictionary with the
following keys and values.

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

@; --- Placeholders

@defproc[(get-placeholders [conn connection?])
                                    jsexpr?]{
                 Returns a @tech[#:doc '(lib "json/json.scrbl")]{jsexpr}
                 containing details of all @tech{placeholders}.}

The return value is a list of placeholders. Each placeholder is a dictionary with the
following keys and values.

@tabular[#:sep @hspace[1] #:row-properties '(bottom-border ())
                          #:column-properties '(() () right)
  (list
    (list "Key"              "JSON type of value" "Example")
    (list @tt{id}            @elem{@italic{numeric} (integer)} "23092")
    (list @tt{name}          @italic{string}                   "Resource Required 1")
    (list @tt{archived}      @italic{boolean}                  @tt{false})
    (list @tt{roles}         @elem{@italic{array} of @italic{string}} "[\"Placeholder\"]")
    (list @tt{updated_at}    @elem{@italic{string} (timestamp)}       "")
    (list @tt{updated_by_id} @elem{@italic{numeric} (integer)}        ""))]


@; --- Projects

@defproc[(get-projects [conn connection?])
                             jsexpr?]{

                   Returns a @tech[#:doc '(lib "json/json.scrbl")]{jsexpr}
                   containing details of all @tech{projects}.}

The return value is a list of projects. Each project is a dictionary with the
following keys and values.

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

@; --- Clients

@defproc[(get-clients [conn connection?])
                           jsexpr?]{

                 Returns a @tech[#:doc '(lib "json/json.scrbl")]{jsexpr}
                 containing details of all @tech{clients}.}

The return value is a list of clients. Each clients is a dictionary with the
following keys and values.

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


@; --- Assignments

@defproc[(get-assignments [conn connection?])
                                  jsexpr?]{

                 Returns a @tech[#:doc '(lib "json/json.scrbl")]{jsexpr}
                 containing details of all @tech{assignments}.}

The return value is a list of assignments. Each assignment is a dictionary with the
following keys and values.

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

