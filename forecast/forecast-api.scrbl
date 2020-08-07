#lang scribble/base

@title{A guide to the Forecast API}

@hyperlink["https://forecastapp.com"]{Forecast} is our SaaS system for recording
project assignments. It contains three primary kinds of entity: @emph{person},
representing a member of the REG team, typically also having an account on the
system and an email address; @emph{project}, something to which we assign
people; and @emph{assignment}, a contiguous range of days for which a person is
assigned to a project. With very few exceptions a project is individuated by a
GitHub issue id; the exceptions are ``global projects,'' used for managing
availability.

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
    (list @tt{https://api.forecastapp.com/projects} "Projects")
    (list @tt{https://api.forecastapp.com/people} "Persons")
    (list @tt{https://api.forecastapp.com/schedule} "Assignments"))]
  

@subsection{Persons}

A GET request to the @tt{people} resource returns a dictionary with the
single key @verbatim{people}, whose value is an array of @tt{person}. A
@tt{person} is a dictionary with the following fields:

@tabular[#:sep @hspace[1] #:row-properties '(bottom-border ())
  (list
    (list "Key" "JSON type of value" "Example")
    (list @tt{id}          "Numeric (integer)" "")
    (list @tt{harvest_user_id} "Numeric (integer)" "")
    (list @tt{first_name}  "String" "James")
    (list @tt{last_name}   "String" "Geddes")
    (list @tt{email}       "String" @tt|{jgeddes@turing.ac.uk}|)
    (list @tt{avatar_url}  "String"  "")
    (list @tt{login}       "String" "enabled")
    (list @tt{admin}       "Boolean" "")
    (list @tt{archived}    "Boolean" "")
    (list @tt{color_blind} "Boolean" "")
    (list @tt{roles}       "Array of String" "")
    (list @tt{weekly_capacity} "Numeric (integer)" "144000")          
    (list @tt{working_days} "Dictionary of Boolean" "")
    (list @tt{personal_feed_token_id} "?" @tt{null})
    (list @tt{subscribed}  "Boolean" "")
    (list @tt{updated_at}  "String (timestamp)" "2020-04-08T13:46:01.840Z")
    (list @tt{updated_by_id} "Numeric (integer)" "")
)]

Most of these fields are self-explanatory (or anyway we have guessed
them). Harvest has its own database of users---even though they are the same
users---and @tt{harvest_user_id} connects the user on Forecast with their
dopplegänger on Harvest. The elements of the array in @tt{roles} are
user-defined strings (such as ``REG Permanent'') that are listed in the resource
@tt{roles} (although, oddly, they are given here as their descriptions, rather
than their ids in that resource). The weekly availabilty @tt{weekly_capacity} is
given in seconds. The keys of the dictionary @tt{working_days} are "monday",
"tuesday", and so on, and the values are boolean. 

The meanings of @tt{login}, @tt{personal_feed_token_id}, and
@tt{subscribed} are unknown.
