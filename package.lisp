(uiop:define-package #:nx-mosaic
  (:nicknames #:mosaic)
  (:use #:cl)
  (:import-from #:nyxt
                #:define-class
                #:user-class
                #:define-mode
                #:define-command-global
                #:define-internal-page-command-global
                #:current-buffer
                #:url
                #:buffer
                #:*browser*
                #:theme
                #:ps-eval)
  (:import-from #:serapeum
                #:->
                #:export-always)
  (:documentation "nx-mosaic is an extensible and configurable Nyxt new-buffer page."))
