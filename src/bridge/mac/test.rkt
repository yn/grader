#lang racket
(define (a x)
  (displayln (format "Hello World~a" x)))

(define (b x)
  (a x))

(set! a (lambda (x) (displayln (format "Goodbye World~a" x))))
;;(b 5)
