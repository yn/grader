#lang racket


;; Imports
(require (prefix-in v1: "bridge/mac/v1.rkt"))


;; Main
(define input-grade-file (make-parameter #f))

(unless (input-grade-file)
  (command-line
   #:args (input-file) (input-grade-file input-file)))

(v1:go (input-grade-file))

(module+ test
  ;(require rackunit)
  )
