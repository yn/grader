#lang racket



;; Imports
(require rackjure)
(require 2htdp/batch-io)
(require (prefix-in s: srfi/19))
(require racket/runtime-path)


;; Defines
(define-runtime-path mapping7 "mapping7.csv")
(define-runtime-path mapping28 "mapping28.csv")
(define mappings (make-immutable-hash (list
                                       (cons 7 mapping7)
                                       (cons 28 mapping28))))

;; Provides
(provide go)

;; Things that should've already been part of a reasonably complete programming environment. Candidates for separate module extraction


;; I am quite unhappy with Scheme/Racket's date/time support. ICU is much better thought out.

(define (today-midnight)
  (let* ([r (seconds->date (* 0.001 (current-inexact-milliseconds)))]
         [c (s:make-date 0 0 0 0 (date-day r) (date-month r) (date-year r) (date-time-zone-offset r))])
    c))

(define (yesterday d)
  (~>> (s:make-time s:time-duration 0 (* 24 60 60))
       (s:subtract-duration (s:date->time-utc d))
       (s:time-utc->date)))


;; Why this isn't part of racket already is beyond me. It's certainly part of Clojure out of the box.
(define (stream-iterate f x)
  (stream-cons x (stream-iterate f (f x))))

(define (stream-take s n)
  (if (eq? n 0)
      (list)
      (cons (stream-first s)
            (stream-take (stream-rest s) (- n 1)))))


;; Grade file mapping

(struct grade-line (index grade) #:transparent)
(define list->grade-line (curry apply grade-line))

(define (grade-list-valid? gl)
  (andmap (λ (x y) (equal? (string->number (grade-line-index x)) y))
          gl
          (range (length gl))))

(define (get-grade lookback n)
  (let* ([p (hash-ref mappings lookback)]
         [f (path->string p)]
         [gl (read-csv-file/rows f list->grade-line)])
    (unless (grade-list-valid? gl)
      (error (format "Check ~a" f)))
    (grade-line-grade (list-ref gl (- lookback n)))))

;; Grader 


(struct agenda-line (category head type todo tags date time extra priority-l priority-n agenda-day) #:transparent)
(define list->agenda-line (curry apply agenda-line)) 

(define (csv->date-set f)
  (~>> (read-csv-file/rows f list->agenda-line)                              ;; read file and construct agenda-line
       (filter (λ (x) (regexp-match #rx#"^Clocked:" (agenda-line-extra x)))) ;; only lines with Clocked: in extra
       (map (compose (curryr s:string->date "~Y-~m-~d") agenda-line-date))   ;; convert to struct "date" field
       list->set))                                                           ;; make a set

(define (start-lookback->date-set start lookback)
  (~> (stream-iterate yesterday start)
      (stream-take lookback)
      list->set))

(define (go input output start lookback)
  (let* ([start (or start (today-midnight))]
         [lookback (or lookback 7)]
         [input-dates (csv->date-set input)]
         [calendar-dates (start-lookback->date-set start lookback)]
         [intersection (set-intersect input-dates calendar-dates)]
         [grade (get-grade lookback (set-count intersection))])
    (write-file output grade)
    (void)))

(module+ test
  (require rackunit))
