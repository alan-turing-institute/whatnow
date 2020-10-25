#lang scribble/manual

@title{@bold{whatnow}: Hut23 project planning notifications}

@author{James Geddes}

Whatnow is a tool for producing regular planning reports for all the projects in
Hut23.

@section{Information and warnings}

Whatnow halts with an error if the records retrieved from the servers do not
have the expected fields.

Whatnow then:

@itemlist[
  @item{Warns about missing data in a particular data source;}
  @item{Warns about data that is inconsistent between data sources;}
  @item{Produces informational updates about forthcoming events, of varying levels of
  urgency;}
  @item{Produces various summaries of the data, on request.}
]







@include-section["schedule.scrbl"]
@include-section["config.scrbl"]
@include-section["forecast.scrbl"]
@;@include-section["apis.scrbl"]

