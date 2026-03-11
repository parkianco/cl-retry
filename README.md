# cl-retry

Pure Common Lisp exponential backoff retry library with zero external dependencies.

## Installation

```lisp
(asdf:load-system :cl-retry)
```

## Usage

```lisp
(use-package :cl-retry)

;; Basic retry with exponential backoff
(with-retry (:max-retries 5 :initial-delay 1.0)
  (make-http-request url))

;; Retry only on specific conditions
(with-retry (:max-retries 3 :on (connection-error timeout-error))
  (connect-to-server))

;; Custom backoff parameters
(with-retry (:max-retries 10
             :initial-delay 0.5
             :max-delay 30.0
             :multiplier 2.0
             :jitter 0.2)
  (flaky-operation))

;; Using retry policy
(let ((policy (make-retry-policy :max-retries 5
                                  :initial-delay 1.0)))
  (retry-on-condition 'connection-error
                      (lambda () (connect))
                      :policy policy))

;; Calculate delay manually
(exponential-backoff 3 :initial-delay 1.0)  ; Delay for attempt 3
```

## API

- `with-retry` - Main retry macro with exponential backoff
- `retry-with-backoff` - Alias for with-retry
- `retry-on-condition` - Retry function on specific condition type
- `make-retry-policy` - Create retry configuration
- `exponential-backoff` - Calculate backoff delay
- `jitter` - Add random jitter to delay
- `compute-delay` - Compute delay from policy and attempt

## License

BSD-3-Clause. Copyright (c) 2024-2026 Parkian Company LLC.
