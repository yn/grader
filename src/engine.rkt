#lang racket


;; Imports
(require (prefix-in v1: "engine/v1.rkt"))


;; Main
(define start-date (make-parameter #f))
(define input-csv-file (make-parameter #f))
(define output-grade-file (make-parameter #f))
(define lookback-days (make-parameter #f))

(unless (and (input-csv-file) (output-grade-file)
             (start-date) (lookback-days))
  (command-line
   #:once-each
   [("-s" "--start") date "Start date, YYYY-MM-DD. Default: today" (start-date date)]
   [("-d" "--days") days "Number of lookback days. Default: 7" (lookback-days days)]
   #:args (input-file output-file)
   (input-csv-file input-file)
   (output-grade-file output-file)))

(v1:go (input-csv-file)
       (output-grade-file)
       (lookback-days)
       (start-date))


;; Tests


(module+ test 
  ;(require rackunit)
  ;(check andmap number? fish)
  ;(check-equal? 3 (feed 2))
  )

 
