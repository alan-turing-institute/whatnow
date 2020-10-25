#lang scribble/manual

@require[
  @for-label[racket/base]
  @for-label[basedir]
  @for-label["../config.rkt"]]
             
@title{Configuration}

There are three kinds of configuration data in Whatnow:
@itemlist[#:style 'ordered

  @item{Defaults for various program options.}

  @item{Data the is required for a local installation of Whatnow, such as the
  specifics of where to find the various servers. This kind of data is held in
  Racket modules. See @secref["local-configuration"].}

  @item{Data that should not be made public, such as authentication keys. These
  settings are stored in configuration files that must be created by the user
  and stored in a directory following the XDG standard. See @secref["secrets"].}
  ]   


@section[#:tag "local-configuration"]{Local configuration}

@defmodule[whatnow/api/local-config]{The
@racketmodname[whatnow/api/local-config] library exports settings specific to a
local installation.}

@defthing[FORECAST-SERVER string? #:value "api.forecastapp.com"]{The web address of the Forecast API servier}

@section[#:tag "secrets"]{Secrets}

@defmodule[whatnow/config]{The @racketmodname[whatnow/config] library retrieves
local configuration information from a config file. This information is mainly
account authentication details which should not be stored with the source code.}

@defstruct*[server-account ([id string?] [token string?]) #:transparent]{A
structure type for internet @deftech{server account}s. A @tech{server account}
consists of an account identifier and an authentication token. The details of
@racket{id} and @racket{token} are specific to the server.}

@defproc[(config-get-accounts [secret-file-name string? "secrets.txt"]) (listof
pair?)]{Retrieve secrets from a configuration file. The configuration file is
looked for in the directories specified by the
@secref["XDG_Basedir_Specification" #:doc '(lib "basedir/basedir.scrbl")] using
@racket[list-config-files].}

Calling @racket[config-get-accounts] returns an association list. Presently there is a single key,
@racket['forecast], and the value is a @tech{server account} structure.





                    
