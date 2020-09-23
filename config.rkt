#lang racket/base

;; Manage local configuration, obtained from config files

(require racket/function
         racket/contract
         basedir)

(provide
 (struct-out server-account)
 config-get-accounts)


;; A server-account is a generic store for an "identifier" and an "authentication token".
(struct server-account (id token) #:transparent)

;; config-get-accounts : string? -> [List-of pair?]  
;; Retrieve account details from secrets file
(define (config-get-accounts [secrets-file-name "secrets.txt"])
  (let* ([path-to-secrets-file
          (get-secrets-file secrets-file-name)]
         [config-dict
          (make-immutable-hash
           (with-input-from-file path-to-secrets-file
             (thunk (read))))])
    ;; Return an association list of accounts
    (list
     (cons 'forecast (get-forecast-account config-dict)))))

(define (get-secrets-file secrets-file-name)
  (let ([path-to-secrets-file (list-config-files secrets-file-name #:program "whatnow")])
    (if (null? path-to-secrets-file)
        (raise-user-error "Unable to find the secrets file.")
        (car path-to-secrets-file))))

(define (get-forecast-account config-dict)
  (server-account
   (hash-ref config-dict 'forecast-account-id)
   (hash-ref config-dict 'harvest-access-token)))




