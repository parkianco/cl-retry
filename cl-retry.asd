;;;; cl-retry.asd
;;;; Exponential backoff retry with zero external dependencies

(asdf:defsystem #:cl-retry
  :description "Pure Common Lisp exponential backoff retry library"
  :author "Parkian Company LLC"
  :license "BSD-3-Clause"
  :version "1.0.0"
  :serial t
  :components ((:file "package")
               (:module "src"
                :serial t
                :components ((:file "retry")))))
