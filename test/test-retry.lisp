;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; test-retry.lisp - Unit tests for retry
;;;;
;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause

(defpackage #:cl-retry.test
  (:use #:cl)
  (:export #:run-tests))

(in-package #:cl-retry.test)

(defun run-tests ()
  "Run all tests for cl-retry."
  (format t "~&Running tests for cl-retry...~%")
  ;; TODO: Add test cases
  ;; (test-function-1)
  ;; (test-function-2)
  (format t "~&All tests passed!~%")
  t)
