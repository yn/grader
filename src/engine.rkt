#lang racket

;; Imports
(require (prefix-in v1: "engine/v1.rkt"))
(require (prefix-in c: "config.rkt"))

;; Main
(define start-date (make-parameter #f))
(define input-csv-file (make-parameter #f))
(define output-grade7-file (make-parameter #f))
(define output-grade28-file (make-parameter #f))

;;move this to utils when one exists
;; (when (regexp-match #rx#"racket-mode" (vector-ref (current-command-line-arguments) 0))
;;   (current-command-line-arguments (vector-drop (current-command-line-arguments) 1)))
;; (command-line
;;  #:once-each
;;  [("-s" "--start") date "Start date, YYYY-MM-DD. Default: today" (start-date date)]
;;  [("-i" "--input-file") input-file "Input CSV org-agenda file" (input-csv-file input-file)]
;;  [("-o" "--output-file") output-file "Output grade file" (output-grade-file output-file)])

(unless (output-grade7-file) (output-grade7-file c:grade7-file))
(unless (output-grade28-file) (output-grade28-file c:grade28-file))
(unless (input-csv-file) (input-csv-file c:csv-file ))

(v1:go (input-csv-file) (output-grade7-file) (start-date) 7)
(v1:go (input-csv-file) (output-grade28-file) (start-date) 28)


;; Tests


(module+ test 
  ;(require rackunit)
  ;(check andmap number? fish)
  ;(check-equal? 3 (feed 2))
  )

 
