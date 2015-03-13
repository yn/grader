#lang racket

(require (except-in ffi/unsafe ->)
         ffi/unsafe/objc         
         ffi/unsafe/nsstring
         ffi/unsafe/nsalloc
         rackjure 
         )

(provide base03 
         base02 
         base01 
         base00 
         base0  
         base1  
         base2  
         base3  
         yellow 
         orange 
         red    
         magenta
         violet 
         blue   
         cyan   
         green)  

(import-class NSColor)

(struct rgb (r g b))
(define list->rgb (curry apply rgb))

(define (nscolor-from-rgb-list rgb-list)
  (let ([c (~> (lambda (x) (if (zero? x) 0.0 (/ x 256.0)))
               (map rgb-list)
               list->rgb)])
    (tell (tell NSColor
                colorWithCalibratedRed: #:type _double (rgb-r c)
                green: #:type _double (rgb-g c)
                blue: #:type _double (rgb-b c)
                alpha: #:type _double 1.0) retain)))

(define base03     (nscolor-from-rgb-list '(  0  43  54)))
(define base02     (nscolor-from-rgb-list '(  7  54  66)))
(define base01     (nscolor-from-rgb-list '( 88 110 117)))
(define base00     (nscolor-from-rgb-list '(101 123 131)))
(define base0      (nscolor-from-rgb-list '(131 148 150)))
(define base1      (nscolor-from-rgb-list '(147 161 161)))
(define base2      (nscolor-from-rgb-list '(238 232 213)))
(define base3      (nscolor-from-rgb-list '(253 246 227)))
(define yellow     (nscolor-from-rgb-list '(181 137   0)))
(define orange     (nscolor-from-rgb-list '(203  75  22)))
(define red        (nscolor-from-rgb-list '(220  50  47)))
(define magenta    (nscolor-from-rgb-list '(211  54 130)))
(define violet     (nscolor-from-rgb-list '(108 113 196)))
(define blue       (nscolor-from-rgb-list '( 38 139 210)))
(define cyan       (nscolor-from-rgb-list '( 42 161 152)))
(define green      (nscolor-from-rgb-list '(133 153   0)))
