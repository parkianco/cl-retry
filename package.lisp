;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause

;;;; package.lisp
;;;; Package definition for cl-retry

(defpackage #:cl-retry
  (:use #:cl)
  (:export
   ;; Main retry macros
   #:with-retry
   #:retry-with-backoff
   ;; Configuration
   #:max-retries
   #:retry-delay
   #:exponential-backoff
   #:jitter
   ;; Condition-based retry
   #:retry-on-condition
   #:retry-on
   ;; Retry policy
   #:make-retry-policy
   #:retry-policy
   #:retry-policy-max-retries
   #:retry-policy-initial-delay
   #:retry-policy-max-delay
   #:retry-policy-multiplier
   #:retry-policy-jitter
   ;; Conditions
   #:retry-exhausted
   #:retry-exhausted-attempts
   #:retry-exhausted-last-error
   ;; Utilities
   #:compute-delay))
