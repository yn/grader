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

;;; Classes
(import-class NSObject)
(import-class NSStatusBar)
(import-class NSStatusItem)
(import-class NSMenu)
(import-class NSMenuItem)
(import-class NSFont)
(import-class NSMutableDictionary)
(import-class NSAttributedString)

(define (quit handler timer status-item)
  (when timer (send timer stop))
  (when status-item
    (let* ([statusbar (tell NSStatusBar systemStatusBar)])
      (tell statusbar removeStatusItem: status-item)))
  (void))

(unless (objc_lookUpClass "Holder")
  (define-objc-class Holder NSObject
    [timer status-item]
    (- _void (quit: [_id sender])
       (quit self timer status-item)
       (tell self release))
    (- _void (dealloc)
       (void)
       ;;(write-file "/tmp/yourmom.txt" "Hi")
       )))
(import-class Holder)

(define global-status-item #f)
(define grade-file "/Users/yn/code/mine/grader/grade")

(define grade->color-mapping (make-hash (list
                                         (cons "A" s:green)
                                         (cons "B" s:cyan)
                                         (cons "C" s:orange)
                                         (cons "D" s:red)
                                         (cons "F" s:red))))

(define (ns-font name size)
  (tell NSFont fontWithName: #:type _NSString name size: #:type _double (* 1.0 size)))

(define (set-attribute! a k v)
  (tell a setObject: v forKey: #:type _NSString k))

(define (ns-attributed-string s a)
  (tell (tell NSAttributedString alloc) initWithString: #:type _NSString s attributes: a))

(define (get-attributed-string grade [mtime #f])
  (let* ([attributes (tell NSMutableDictionary new)]
         [major-grade (substring grade 0 1)])
    (set-attribute! attributes "NSFont" (ns-font "Monaco" 14))
    (set-attribute! attributes "NSBackgroundColor" s:base01)
    (when (hash-has-key? grade->color-mapping major-grade)
      (set-attribute! attributes "NSColor" (hash-ref grade->color-mapping major-grade)))
    (ns-attributed-string grade attributes)
    ))

(define (tick status-item)
  (with-handlers ([exn:fail? (λ (e) (tellv status-item setAttributedTitle: (get-attributed-string "IOE")))])
    (tellv status-item setAttributedTitle: (get-attributed-string (read-file "/tmp")))))

(define (go)  
 (with-autorelease
   (let* ([statusbar (tell NSStatusBar systemStatusBar)]
          [status-item (tell statusbar statusItemWithLength: #:type _CGFloat -1.0)]
          [menu (tell NSMenu new)]
          [menu-item (tell (tell NSMenuItem alloc) initWithTitle: #:type _NSString "Quit" action: #:type _SEL (selector quit:) keyEquivalent: #:type _NSString "")]
          [holder (tell Holder new)])
     (set! global-status-item (tell status-item retain))
     (tellv status-item setAttributedTitle: (get-attributed-string "I"))
     ;;(tellv status-item setAttributedTitle: #:type _NSString "Hi")
     (tellv status-item setHighlightMode: #:type _int 1)
     (tellv menu-item setTarget: holder)
     (tellv menu addItem: menu-item)
     (tellv status-item setMenu: menu)
     (set-ivar! holder status-item status-item)
     (set-ivar! holder timer (new timer% 
                                  [notify-callback (partial tick status-item)]
                                  [interval 5000]))
     
     
     )
  
   ;; (set! menu       (menu:init-with-title "Screenshot"))
 
   ;; (set! menu-item1 (menu-item:init-with-title "capture1"))
   ;; (menu-item:set-enabled menu-item1 #t)
   ;; (menu:add-item menu menu-item1)

   ;; (set! menu-item2 (menu-item:init-with-title "capture2"))
   ;; (menu-item:set-enabled menu-item2 #t)
   ;; (menu:add-item menu menu-item2)
 
   ;; (status-item:set-menu status-item menu)
   ;; ; (menu:set-menu-bar-visible menu #t)
 
   ;; (status-item:set-enabled status-item #t)

   ))                                   ; respond to clicks
;;(go)
