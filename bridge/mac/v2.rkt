#lang racket
(require ffi/unsafe
         ffi/unsafe/objc         
         ffi/unsafe/nsstring
         ffi/unsafe/nsalloc
         (except-in racket/gui ->)
         2htdp/batch-io
         rackjure/utils
         (prefix-in s:"solarized.rkt") )

(ffi-lib
 "/System/Library/Frameworks/Foundation.framework/Foundation")
(ffi-lib
 "/System/Library/Frameworks/AppKit.framework/AppKit")

;;; Types
(define _CGFloat _double)
(define _NSStatusItem _id)

;;; Constants
(define NSVariableStatusItemLength -1) 

;;; ObjC utilities
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
    [timer status-item]
    (- _void (quit: [_id sender])
       (when timer (send timer stop))
       (let* ([statusbar (tell NSStatusBar systemStatusBar)])
         (tellv statusbar removeStatusItem: status-item))
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


(define global-status-item #f)
(define grade-file "/Users/yn/code/mine/grader/grade")

(define grade->color-mapping (make-hash (list
                                         (cons "A" s:green)
                                         (cons "B" s:cyan)
                                         (cons "C" s:orange)
                                         (cons "D" s:red)
                                         (cons "F" s:red))))


(define (get-attributed-string grade [mtime #f])
  (let* ([h (make-hash)]
         [major-grade (substring grade 0 1)])
    (hash-set! h "NSFont" (ns-font "Monaco" 14))
    (hash-set! h "NSBackgroundColor" s:base01)
    (when (hash-has-key? grade->color-mapping major-grade)
      (hash-set! h "NSColor" (hash-ref grade->color-mapping major-grade)))
    (ns-attributed-string grade (hash->ns-dictionary h)))) 

(define (tick status-item)
  (with-handlers ([exn:fail? (λ (e) (tellv status-item setAttributedTitle: (get-attributed-string "IOE")))])
    (tellv status-item setAttributedTitle: (get-attributed-string (read-file grade-file)))))

(define (go)  
 (with-autorelease
   (let* ([statusbar (tell NSStatusBar systemStatusBar)]
          [status-item (tell statusbar statusItemWithLength: #:type _CGFloat -1.0)]
          [menu (tell NSMenu new)]
          [menu-item (ns-menu-item "Quit" (selector quit:) "")]
          [holder (tell Holder new)])
     (set! global-status-item (tell status-item retain))
     (tellv status-item setAttributedTitle: (get-attributed-string "I"))
     (tellv status-item setHighlightMode: #:type _int 1)
     (tellv menu-item setTarget: holder)
     (tellv menu addItem: menu-item)
     (tellv status-item setMenu: menu)
     (set-ivar! holder status-item status-item)
     (set-ivar! holder timer (new timer% 
                                  [notify-callback (partial tick status-item)]
                                  [interval 5000])))))
;;(go)
