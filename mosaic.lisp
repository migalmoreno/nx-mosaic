;; TODO: Add bookmark widget
;; TODO: Add weather widget
(in-package #:nx-mosaic)
(nyxt:use-nyxt-package-nicknames)

(define-class font-settings ()
  ((font-size
    14
    :type number
    :documentation "The font size to use."))
  (:export-class-name-p t)
  (:export-accessor-names-p t)
  (:export-slot-names-p t)
  (:accessor-name-transformer (class*:make-name-transformer name))
  (:documentation "The font settings to use throughout widgets.")
  (:metaclass user-class))

(define-class widget ()
  ((font-settings
    (make-instance 'font-settings)
    :type font-settings
    :documentation "The font settings for the widget.")
   (visible-p
    t
    :type boolean
    :documentation "Whether the widget should be shown."))
  (:export-class-name-p t)
  (:export-accessor-names-p t)
  (:export-slot-names-p t)
  (:accessor-name-transformer (class*:make-name-transformer name))
  (:documentation "An individual widget.")
  (:metaclass user-class))

(defgeneric display-widget (widget buffer)
  (:documentation "Display the markup of WIDGET in BUFFER."))

(define-class time-widget (widget)
  ((timezone
    nil
    :type (or null string)
    :documentation "The timezone to display time for.")
   (font-settings
    (make-instance 'font-settings
                   :font-size 80)))
  (:export-class-name-p t)
  (:export-accessor-names-p t)
  (:export-slot-names-p t)
  (:accessor-name-transformer (class*:make-name-transformer name))
  (:documentation "A time widget."))

(defmethod display-widget ((widget time-widget) buffer)
  (let ((time-style
          (theme:themed-css (theme *browser*)
            ("#time"
             :font-size (font-size (font-settings widget))))))
    (hooks:once-on (nyxt:buffer-loaded-hook buffer) (buffer)
      (ps-eval
        :buffer buffer
        (defun set-time ()
          (let ((time (ps:new (-Date))))
            (setf (ps:@ (nyxt/ps:qs document "#time") |innerHTML|)
                  (ps:chain time
                            (|toLocaleString|
                             (array)
                             (ps:create hour "2-digit"
                                        minute "2-digit"
                                        hour12 nil))))))
        (set-time)
        (ps:chain window (|setInterval| |setTime| 1000))))
    (spinneret:with-html-string
      (:style time-style)
      (:div :id "widget-container"
            (:h1 :id "time")))))

(define-class greeting-widget (widget)
  ((name
    nil
    :type (or null string)
    :documentation "The name to show in the greeting.")
   (font-settings
    (make-instance 'font-settings
                   :font-size 40)))
  (:export-class-name-p t)
  (:export-accessor-names-p t)
  (:export-slot-names-p t)
  (:accessor-name-transformer (class*:make-name-transformer name))
  (:documentation "A greeting widget."))

(defmethod display-widget ((widget greeting-widget) buffer)
  (let ((greeting-style (theme:themed-css (theme *browser*)
                          ("#greeting"
                           :font-size (font-size (font-settings widget))))))
    (hooks:once-on (nyxt:buffer-loaded-hook buffer) (buffer)
      (ps-eval
        :buffer buffer
        (defun set-greeting ()
          (let* ((time (ps:new (-Date)))
                 (hour (ps:chain time (|getHours|)))
                 (greetings-mapping
                   (ps:loop :for i :from 0 :to 24
                      :collect (cond
                                 ((< i 3) "Sleep well")
                                 ((and (> i 2) (< i 6)) "Rise and shine")
                                 ((and (> i 5) (< i 10)) "Good morning")
                                 ((and (> i 9) (< i 14)) "Hello")
                                 ((and (> i 13) (< i 18)) "Good afternoon")
                                 ((and (> i 17) (< i 22)) "Good evening")
                                 (t "Good night")))))
            (setf (ps:@ (nyxt/ps:qs document "#message") |innerHTML|)
                  (elt greetings-mapping hour))))
        (set-greeting)
        (ps:chain window (|setInterval| |setGreeting| 60000))))
    (spinneret:with-html-string
      (:style greeting-style)
      (:div
       (:h1 :id "greeting"
            (:p :id "message")
            (:p :id "name"
                   (str:concat (when (name widget)
                                 (str:concat " ," (name widget))))))))))

(defparameter *widgets*
  (list
   (make-instance 'time-widget)
   (make-instance 'greeting-widget))
  "The list of widgets")

(nyxt::define-internal-page-command-global mosaic ()
    (buffer "*Mosaic*" 'nyxt:base-mode)
  "Open a `nx-mosaic' page."
  (let ((mosaic-style (theme:themed-css (theme *browser*)
                        (body
                         :padding 0
                         :margin 0
                         :background theme:background
                         :color theme:on-background)
                        ("#mosaic-container"
                         :height "100vh"
                         :display "flex"
                         :align-items "center"
                         :text-align "center"
                         :flex-wrap "wrap"
                         :justify-content "center"))))
    (spinneret:with-html-string
      (:style mosaic-style)
      (:div :id "mosaic-container"
            (:div :class "widgets-container"
                  (loop for widget in *widgets*
                        collect (:raw (display-widget widget buffer))))))))
