;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; cl-retry.asd
;;;; Exponential backoff retry with zero external dependencies

(asdf:defsystem #:cl-retry
  :description "Pure Common Lisp exponential backoff retry library"
  :author "Parkian Company LLC"
  :license "BSD-3-Clause"
  :version "0.1.0"
  :serial t
  :components ((:file "package")
               (:module "src"
                :serial t
                :components ((:file "retry")))))

(asdf:defsystem #:cl-retry/test
  :description "Tests for cl-retry"
  :depends-on (#:cl-retry)
  :serial t
  :components ((:module "test"
                :components ((:file "test-retry"))))
  :perform (asdf:test-op (o c)
             (let ((result (uiop:symbol-call :cl-retry.test :run-tests)))
               (unless result
                 (error "Tests failed")))))
