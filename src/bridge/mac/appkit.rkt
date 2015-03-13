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

(define (menu:init)
  ; Note: Retain to it to keep it.
  (tell (tell NSMenu alloc) init))

(define (menu:add-item menu menu-item)
  (tellv menu addItem: menu-item))

(define (menu:set-menu-bar-visible menu flag)
  (tellv menu setMenuBarVisible: flag))

(define (menu-item:init-with-title name [action #f] [char-code ""])
  (tell (tell NSMenuItem alloc) initWithTitle:
        #:type _NSString name action:
        #:type _SEL action keyEquivalent:
        #:type _NSString char-code))

(define (menu-item:set-submenu menu-item menu)
  (tellv menu-item setSubmenu: menu))

(define (menu-item:set-target menu-item obj)
  (tellv menu-item setTarget: obj))

(define (menu-item:set-menu menu-item menu)
  (tellv menu-item setMenu: menu))

(define (menu-item:set-enabled menu-item flag)
  (tellv menu-item setEnabled: #:type _bool flag))
