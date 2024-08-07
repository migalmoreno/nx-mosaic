(defsystem #:nx-mosaic
  :description "nx-mosaic is an extensible and configurable new-buffer page for Nyxt."
  :author "Miguel Ángel Moreno"
  :license "BSD 3-Clause"
  :version "0.0.1"
  :serial t
  :depends-on (#:nyxt)
  :components ((:file "package")
               (:file "mosaic")))
