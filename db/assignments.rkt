#lang racket/base

#|

Utilities for dealing with assignments. 

An assignment is a contiguous period of time, a project and a person, together
with a resource level.

We use the following terms:

- allocation: 
  A continuous period of time between given dates, together with a resource
  level (in seconds per day).

- assignment: 
  An allocation, together with a project and a person.

|#

; (provide )


(require gregor
         "types.rkt")

;; ---------------------------------------------------------------------------------------------------
;; Utility functions for spans of time



;; ---------------------------------------------------------------------------------------------------
;; Utility function for resource levels
