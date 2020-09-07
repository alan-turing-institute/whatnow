#lang racket/base

(require racket/function
         basedir)

(require
 (only-in "local-config.rkt" FORECAST-HOSTNAME)
 (prefix-in forecast- "api/forecast.rkt"))


;;; Get local secrets

(define path-to-config-file
  (list-config-files "secrets.txt" #:program "whatnow"))

(define configuration-values
  (make-immutable-hash
   (with-input-from-file (car path-to-config-file)
     (thunk (read)))))


;;; Make Forecast connection

(define fc
  (forecast-connect FORECAST-HOSTNAME
           (hash-ref configuration-values 'forecast-account-id)
           (hash-ref configuration-values 'harvest-access-token)))





