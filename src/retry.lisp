;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause

;;;; retry.lisp
;;;; Exponential backoff retry implementation

(in-package #:cl-retry)

;;; Conditions

(define-condition retry-exhausted (error)
  ((attempts :initarg :attempts :reader retry-exhausted-attempts)
   (last-error :initarg :last-error :reader retry-exhausted-last-error))
  (:report (lambda (c s)
             (format s "Retry exhausted after ~D attempts. Last error: ~A"
                     (retry-exhausted-attempts c)
                     (retry-exhausted-last-error c)))))

;;; Retry Policy

(defstruct (retry-policy (:constructor %make-retry-policy))
  "Configuration for retry behavior."
  (max-retries 3 :type fixnum)
  (initial-delay 1.0 :type real)         ; seconds
  (max-delay 60.0 :type real)            ; seconds
  (multiplier 2.0 :type real)            ; exponential factor
  (jitter 0.1 :type real))               ; random factor (0.0 - 1.0)

(defun make-retry-policy (&key (max-retries 3)
                               (initial-delay 1.0)
                               (max-delay 60.0)
                               (multiplier 2.0)
                               (jitter 0.1))
  "Create a retry policy."
  (%make-retry-policy :max-retries max-retries
                      :initial-delay (coerce initial-delay 'single-float)
                      :max-delay (coerce max-delay 'single-float)
                      :multiplier (coerce multiplier 'single-float)
                      :jitter (coerce jitter 'single-float)))

;;; Delay Computation

(defun compute-delay (policy attempt)
  "Compute the delay for ATTEMPT using POLICY with exponential backoff."
  (let* ((base-delay (* (retry-policy-initial-delay policy)
                        (expt (retry-policy-multiplier policy) attempt)))
         (capped-delay (min base-delay (retry-policy-max-delay policy)))
         (jitter-range (* capped-delay (retry-policy-jitter policy)))
         (jitter-amount (- (random (* 2.0 jitter-range)) jitter-range)))
    (max 0.0 (+ capped-delay jitter-amount))))

(defun exponential-backoff (attempt &key (initial-delay 1.0)
                                         (max-delay 60.0)
                                         (multiplier 2.0)
                                         (jitter 0.1))
  "Calculate exponential backoff delay for ATTEMPT."
  (let ((policy (make-retry-policy :initial-delay initial-delay
                                   :max-delay max-delay
                                   :multiplier multiplier
                                   :jitter jitter)))
    (compute-delay policy attempt)))

(defun jitter (base-delay &optional (jitter-factor 0.1))
  "Add random jitter to BASE-DELAY."
  (let* ((jitter-range (* base-delay jitter-factor))
         (jitter-amount (- (random (* 2.0 jitter-range)) jitter-range)))
    (max 0.0 (+ base-delay jitter-amount))))

;;; Retry Functions

(defun retry-delay (seconds)
  "Sleep for SECONDS (with fractional support)."
  (sleep seconds))

(defun max-retries (count)
  "Return a retry policy with COUNT max retries."
  (make-retry-policy :max-retries count))

(defun retry-on-condition (condition-type function &key (policy (make-retry-policy)))
  "Retry FUNCTION when CONDITION-TYPE is signaled, using POLICY."
  (let ((attempts 0)
        (last-error nil))
    (loop
      (handler-case
          (return (funcall function))
        (error (e)
          (if (typep e condition-type)
              (progn
                (setf last-error e)
                (incf attempts)
                (when (>= attempts (retry-policy-max-retries policy))
                  (error 'retry-exhausted
                         :attempts attempts
                         :last-error last-error))
                (retry-delay (compute-delay policy attempts)))
              (error e)))))))

;;; Main Retry Macros

(defmacro with-retry ((&key (max-retries 3)
                            (initial-delay 1.0)
                            (max-delay 60.0)
                            (multiplier 2.0)
                            (jitter 0.1)
                            (on '(error)))
                      &body body)
  "Execute BODY, retrying on error up to MAX-RETRIES times with exponential backoff.

   :on - List of condition types to retry on (default: (error))
   :max-retries - Maximum number of retry attempts
   :initial-delay - Initial delay in seconds
   :max-delay - Maximum delay in seconds
   :multiplier - Exponential backoff multiplier
   :jitter - Random jitter factor (0.0 - 1.0)"
  (let ((attempts (gensym "ATTEMPTS"))
        (last-error (gensym "LAST-ERROR"))
        (policy (gensym "POLICY"))
        (result (gensym "RESULT"))
        (condition-types (if (listp on) on (list on))))
    `(let ((,attempts 0)
           (,last-error nil)
           (,policy (make-retry-policy :max-retries ,max-retries
                                       :initial-delay ,initial-delay
                                       :max-delay ,max-delay
                                       :multiplier ,multiplier
                                       :jitter ,jitter)))
       (block retry-block
         (loop
           (handler-case
               (let ((,result (progn ,@body)))
                 (return-from retry-block ,result))
             ,@(mapcar (lambda (ctype)
                         `(,ctype (e)
                            (setf ,last-error e)
                            (incf ,attempts)
                            (when (>= ,attempts (retry-policy-max-retries ,policy))
                              (error 'retry-exhausted
                                     :attempts ,attempts
                                     :last-error ,last-error))
                            (retry-delay (compute-delay ,policy ,attempts))))
                       condition-types)))))))

(defmacro retry-with-backoff ((&rest policy-args) &body body)
  "Execute BODY with exponential backoff retry.
   POLICY-ARGS are passed to WITH-RETRY."
  `(with-retry (,@policy-args)
     ,@body))

(defmacro retry-on (condition-types (&rest policy-args) &body body)
  "Execute BODY, retrying only on specified CONDITION-TYPES."
  (let ((types (if (listp condition-types) condition-types (list condition-types))))
    `(with-retry (:on ',types ,@policy-args)
       ,@body)))
