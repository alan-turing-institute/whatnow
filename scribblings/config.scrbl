#lang scribble/manual

@require[
  @for-label[racket/base]
  @for-label[basedir]
  @for-label["../config.rkt"]]
             
@title{Local configuration}

@defmodule[whatnow/config]{The @racketmodname[whatnow/config] library retrieves local configuration
information from a config file. This information is mainly account details which should not be stored
with the source code.}

@defstruct*[server-account ([id string?] [token string?]) #:transparent]{A structure type for internet
@deftech{server account}s. A @tech{server account} consists of an account identifier and an
authentication token. The details of @racket{id} and @racket{token} are specific to the server.}

@defproc[(config-get-accounts [secret-file-name string? "secrets.txt"]) (listof pair?)]{Retrieve secrets from a
configuration file. The configuration file is looked for in the directories specified by the
@secref["XDG_Basedir_Specification" #:doc '(lib "basedir/basedir.scrbl")] using @racket[list-config-files].}

Calling @racket[config-get-accounts] returns an association list. Presently there is a single key,
@racket['forecast], and the value is a @tech{server account} structure.





                    
