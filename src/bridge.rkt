#lang racket


;; Imports
(require (prefix-in v1: "bridge/mac/v1.rkt"))
(require (prefix-in c: "config.rkt"))


;; Main
(define input-grade-file (make-parameter #f))

;;move this to utils when one exists
(when (regexp-match #rx#"racket-mode" (vector-ref (current-command-line-arguments) 0))
  (current-command-line-arguments (vector-drop (current-command-line-arguments) 1)))
(command-line
 #:once-each
 [("-i" "--input-file") input-file "Input grade file" (input-grade-file input-file)])

(unless (input-grade-file) (input-grade-file c:grade-file))

(v1:go (input-grade-file))

(module+ test
  ;(require rackunit)
  )
