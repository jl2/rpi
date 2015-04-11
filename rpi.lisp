;; rpi.lisp

;; Copyright (c) 2015, Jeremiah LaRocco <jeremiah.larocco@gmail.com>

;; Permission to use, copy, modify, and/or distribute this software for any
;; purpose with or without fee is hereby granted, provided that the above
;; copyright notice and this permission notice appear in all copies.

;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
;; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
;; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
;; ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
;; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
;; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
;; OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

(in-package #:rpi)

;; Set safety and debug to 1 because they don't add much code, and prevent segfaults
(declaim (optimize (speed 3) (safety 1) (debug 1) (size 0) ))

(declaim (inline enable-pin disable-pin set-mode set-pin read-pin))

;; Just about the simplest CFFI interface ever...

;; Use libgpio
(define-foreign-library libgpio
  (:unix "libgpio.so")
  (t (:default "libgpio")))

(use-foreign-library libgpio)

;; Define the direction enum
(defcenum direction
    (:in 0)
  (:out 1))

;; Declare the imported functions
(defcfun "enable_pin" :void (pin :int))
(defcfun "disable_pin" :void (pin :int) )
(defcfun "set_pin" :void (pin :int) (val :int))
(defcfun "set_direction" :void (pin :int) (dir direction))
(defcfun "read_pin" :void (pin :int))
