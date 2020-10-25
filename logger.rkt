#lang racket/base

#|
Define a new logger for reporting whatnow-related messages

Whatnow reporting is outside the standard logger (that is, messages are not
propagated to standard error).

|#

(provide
 whatnow-logger
 )

(define whatnow-logger
  (make-logger 'whatnow #f))

(define whatnow-log-receiver
  (make-log-receiver whatnow-logger 'debug))

(define (whatnow-listener)
  (let loop ()
    (let ([message (sync whatnow-log-receiver)])
      (show-whatnow-message message))))

(define (show-whatnow-message msg)
  (displayln "Whatnow reports:")
  (printf "    Level: ~a\n" (vector-ref msg 0))
  (printf "    Topic: ~a\n" (vector-ref msg 3))
  (printf "  Message: ~a\n" (vector-ref msg 1))
  (printf "     Data: ~a\n" (vector-ref msg 2)) )

(define whatnow-reporter-thread
  (thread whatnow-listener))

