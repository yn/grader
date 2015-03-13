#lang racket/gui

(new timer% 
     [notify-callback (lambda () (void))]
     [interval 1000])

(require ffi/unsafe
         ffi/unsafe/objc         
         ffi/unsafe/nsstring)

(provide  
 ; NSStatusBar
 ; is-vertical?
 ; thickness
 ; status-item-with-length
 ; remove-status-item
 ; NSStatusItem
 status-item:set-title
 status-item:get-title
 status-item:set-attributed-title)

;;;
;;; Types
;;;

(define _CGFloat _double)
(define _NSStatusItem _id)

;;;
;;; Constants
;;;

(define NSVariableStatusItemLength -1) ; text
(define NSSquareStatusItemLength   -2) ; icons

;;;
;;; NSStatusBar
;;;

(import-class NSStatusBar)
(import-class NSObject)

(define the-system-status-bar (tell NSStatusBar systemStatusBar))

(define (status-bar:is-vertical?)
  ; is the system bar vertical?
  (tell the-system-status-bar isVertical))

(define (status-bar:thickness)
  ; thickness of system bar in pixels
  (tell #:type _CGFloat the-system-status-bar thickness))

(define (status-bar:status-item-with-length length)
  ; Returns a newly created status item that has been 
  ; allotted a specified space within the status bar.
  (tell
   (tell #:type _NSStatusItem 
         the-system-status-bar statusItemWithLength: #:type _CGFloat (* 1.0 length))
   retain))

(define (status-bar:remove-status-item item)
  (tellv the-system-status-bar removeStatusItem: item))

;;;
;;; NSStatusItem
;;;

(import-class NSStatusItem)

(define (status-item:set-title status-item title) 
  (tellv status-item setTitle: #:type _NSString title))

(define (status-item:get-title status-item)
  (tell #:type _NSString status-item title))

(define (status-item:set-attributed-title status-item title) 
  (tellv status-item setAttributedTitle: #:type _NSString title))

(define (status-item:set-highlight-mode status-item flag)
  ; Sets whether the receiver is highlighted 
  ; when it is clicked. Default is false.
  (tellv status-item setHighlightMode: #:type _bool flag))

(define (status-item:set-menu status-item menu)
  ; Sets the pull-down menu that is displayed 
  ; when the receiver is clicked.
  (tellv status-item setMenu: menu))

(define (status-item:pop-up-status-item-menu status-item menu)
  (tellv status-item popUpStatusItemMenu: menu))

(define (status-item:set-enabled status-item flag)
  ; dis/enable to respond to clicks
  (tellv status-item setEnabled: #:type _bool flag))

(define (status-item:set-tool-tip status-item tool-tip)
  (tellv status-item setToolTip: #:type _NSString tool-tip))

;;;
;;; NSMenu
;;;

(import-class NSMenu)

(define (menu:init-with-title title)
  ; Note: Retain to it to keep it.
  (tell (tell NSMenu alloc)
        initWithTitle: #:type _NSString title))

(define (menu:add-item menu menu-item)
  (tellv menu addItem: menu-item))

(define (menu:set-menu-bar-visible menu flag)
  (tellv menu setMenuBarVisible: flag))

;;;
;;; NSMenuItem
;;;

(import-class NSMenuItem)
(define _NSMenuItem _id)

(define (menu-item:init-with-title name [action #f] [char-code ""])
  (tell (tell NSMenuItem alloc) 
        initWithTitle: #:type _NSString name
        action:        #:type _SEL action
        keyEquivalent: #:type _NSString char-code))

(define (menu-item:set-submenu menu-item menu)
  (tellv menu-item setSubmenu: menu))

(define (menu-item:set-target menu-item obj)
  (tellv menu-item setTarget: obj))

(define (menu-item:set-menu menu-item menu)
  (tellv menu-item setMenu: menu))

(define (menu-item:set-enabled menu-item flag)
  (tellv menu-item setEnabled: #:type _bool flag))

; Example

(define-objc-class Holder NSObject
  [timer status-item]
  (- _void (quit: [_id sender])
     (print 'FROMSTATUS))
  (- _void (dealloc)
     (print 'DEALLOC)))


(require ffi/unsafe/nsalloc
         (except-in racket/gui ->)
         ; (except-in mred/private/wx/cocoa/queue)
         )

(define menu-item1 #f)

(with-autorelease 
 (define status-item 
   (status-bar:status-item-with-length NSVariableStatusItemLength))
 (status-item:set-title status-item "Bar")
 (status-item:set-tool-tip status-item "Bar tooltip")
 (status-item:get-title status-item)
 (status-item:set-attributed-title status-item "Foo")
 (define menu       (menu:init-with-title "Screenshot"))
 
 (set! menu-item1 (menu-item:init-with-title "capture1" (selector quit:)))
 (menu-item:set-enabled menu-item1 #t)
 (menu:add-item menu menu-item1)

 (define menu-item2 (menu-item:init-with-title "capture2"))
 (menu-item:set-enabled menu-item2 #t)
 (menu:add-item menu menu-item2)
 
 (status-item:set-menu status-item menu)
 ; (menu:set-menu-bar-visible menu #t)
 
 (status-item:set-enabled status-item #t)) ; respond to clicks
