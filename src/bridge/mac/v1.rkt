#lang racket
(require ffi/unsafe
         ffi/unsafe/objc         
         ffi/unsafe/nsstring
         ffi/unsafe/nsalloc
         (except-in racket/gui ->)
         2htdp/batch-io
         rackjure/utils
         rackjure/threading
         (prefix-in sl:"solarized.rkt")
         (prefix-in s: srfi/19))

(provide go)

;;; Types
(define _CGFloat _double)
(define _NSStatusItem _id)

;;; Constants
(define NSVariableStatusItemLength -1) 

;;; ObjC utilitiesx
(import-class NSObject)
(import-class NSStatusBar)
(import-class NSStatusItem)
(import-class NSMenu)
(import-class NSMenuItem)
(import-class NSFont)
(import-class NSMutableDictionary)
(import-class NSAttributedString)

(unless (objc_lookUpClass "Holder")
  (define-objc-class Holder NSObject
    [timer status-item q]
    (- _void (quit: [_id sender])
       (q)
       (tellv self release))))
(import-class Holder)

(define (ns-font name size)
  (tell NSFont
        fontWithName: #:type _NSString
        name size: #:type _double (* 1.0 size)))

(define (hash->ns-dictionary h)
  (let ([d (tell NSMutableDictionary new)]
        [for-each-kv (curry hash-for-each h)])
    (for-each-kv 
     (lambda [k v]
       (tell d
             setObject: v
             forKey: #:type _NSString k)))
    d))

(define (ns-attributed-string s a)
  (tell (tell NSAttributedString alloc)
        initWithString: #:type _NSString s
        attributes: a))

(define (ns-menu-item t s k)
  (tell (tell NSMenuItem alloc)
        initWithTitle: #:type _NSString t
        action: #:type _SEL s
        keyEquivalent: #:type _NSString k))

(define grade->color-mapping (make-hash (list
                                         (cons "A" sl:cyan)
                                         (cons "B" sl:green)
                                         (cons "C" sl:orange)
                                         (cons "D" sl:red)
                                         (cons "F" sl:magenta))))

(define (more-than-1-day-ago? seconds)
  (let* ([arg (s:make-time s:time-utc 0 seconds)]
         [now (s:current-time)]
         [day (s:make-time s:time-duration 0 (* 24 60 60))]
         [diff (s:time-difference now arg)])
    (s:time>? diff day)))


(define (get-attributed-string grade [mtime #f])
  (let* ([h (make-hash)]
         [major-grade (substring grade 0 1)])
    (hash-set! h "NSFont" (ns-font "Monaco" 14))
    (if (and mtime (more-than-1-day-ago? mtime))
        (hash-set! h "NSBackgroundColor" sl:base01)
        (hash-set! h "NSBackgroundColor" sl:base2))
    (when (hash-has-key? grade->color-mapping major-grade)
      (hash-set! h "NSColor" (hash-ref grade->color-mapping major-grade)))
    (ns-attributed-string grade (hash->ns-dictionary h))))

(define (tick status-item grade-file)
  (with-handlers
    ([exn:fail? (λ (e) (tellv status-item setAttributedTitle: (get-attributed-string "IOE")))])
    (void)
    (tellv status-item setAttributedTitle:
           (get-attributed-string (read-file grade-file)
                                  (~> grade-file
                                      string->path
                                      file-or-directory-modify-seconds)))))

(define (go input-grade-file interval)  
 (with-autorelease
   (let*
       ([statusbar (tell NSStatusBar systemStatusBar)]
        [status-item (tell (tell statusbar statusItemWithLength: #:type _CGFloat -1.0) retain)]
        [menu (tell NSMenu new)]
        [menu-item (ns-menu-item "Quit" (selector quit:) "")]
        [holder (tell Holder new)]
        [timer (new timer% 
                    [notify-callback (partial tick status-item input-grade-file)]
                    [interval 5000])])
     (send timer notify)
     (tellv status-item setHighlightMode: #:type _int 1)
     (tellv menu-item setTarget: holder)
     (tellv menu addItem: (ns-menu-item interval #f ""))
     (tellv menu addItem: menu-item)
     (tellv status-item setMenu: menu)
     (set-ivar! holder q
                (lambda ()
                  (when timer (send timer stop))
                  (when status-item (tellv statusbar removeStatusItem: status-item)))))))
