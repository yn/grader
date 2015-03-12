#lang racket/gui

;; (define timer (new timer% 
;;                    [notify-callback (lambda () (void))]
;;                    [interval 1000]))

(require ffi/unsafe
         ffi/unsafe/objc         
         ffi/unsafe/nsstring
         ffi/unsafe/nsalloc)

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

(define (quit timer status-item)
  (when timer (send timer stop))
  (when status-item
    (let* ([statusbar (tell NSStatusBar systemStatusBar)])
      (tell statusbar removeStatusItem: status-item)))
  (print 'FROMSTATUS)
  (void))

(define-objc-class Holder NSObject
  [timer status-item]
  (- _void (quit: [_id sender])
     (quit timer status-item))
  (- _void (dealloc)
     (print 'DEALLOC)))

(define status-item #f)
(define menu #f)
(define menu-item1 #f)
(define menu-item2 #f)

(with-autorelease
  (let* ([statusbar (tell NSStatusBar systemStatusBar)]
         [status-item (tell statusbar statusItemWithLength: #:type _CGFloat -1.0)]
         [menu (tell NSMenu new)]
         [menu-item (tell (tell NSMenuItem alloc) initWithTitle: #:type _NSString "Quit" action: #:type _SEL (selector quit:) keyEquivalent: #:type _NSString "")]
         [holder (tell Holder new)])
    (tell holder retain)
    (tell status-item retain)
    (tellv status-item setAttributedTitle: #:type _NSString "Hi")
    (tellv menu-item setEnabled: #:type _bool #t)
    (tellv menu-item setTarget: holder)
    (tellv menu addItem: menu-item)
    (tellv status-item setMenu: menu)
    (set-ivar! holder status-item status-item)
    
    
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

 ) ; respond to clicks
