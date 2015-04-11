;; rpi.asd

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


;; Make sure cffi is loaded before this is processed because
;; the cffi:*foreign-library-directories* is modified
(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package 'cffi)
    (asdf:operate 'asdf:load-op 'cffi)))

;; This is the directory where libgpio.so goes
(defvar *library-file-dir*
  (merge-pathnames "libgpio/"
		   (make-pathname :name nil :type nil
				  :defaults *load-truename*)))

;; This is super ugly, but is the way I found to build a C
;; shared library using ASDF...

;; New type for methods to be called on
(defclass rpi-gpio (c-source-file)
  ())

;; Return the expected output files

(defmethod output-files ((o compile-op) (c rpi-gpio))
  ;; This is ugly, but file-found will be the
  (let* ((file-found
	  ;; some applies the lambda to each of its arguments
	  ;; and returns the first one that's non-nil
	  ;; In this case it checks if libgpio.so exits in /usr/lib/
	  ;; and ./libgpio/,
	  (some #'(lambda (dir)
		    (probe-file (make-pathname :directory dir
					       :name (component-name c)
					       :type "so")))
		(list '(:absolute "usr" "lib")
		      (namestring *library-file-dir*)))))

    ;; Return a list...
    (list
     
     (if file-found
	 ;; If libgpio.so already exists, return the path to it
	 file-found

	 ;; Otherwise return the path of where it gets built
	 (make-pathname :name (component-name c)
			:type "so"
			:defaults *library-file-dir*)))))

;; ASDF calls perform to execute an operation (first argument)
;; on a file of a certain type (second argument)
;; This perform is for a load-op action on a rpi-gpio
;; There's nothing to do, because rpi.lisp handles loading the .so
(defmethod perform ((o load-op) (c rpi-gpio))
  t)

;; operation-done-p checks if the operation  for
;; the file is finished.
;; Since the .so isn't loaded by ASDF, just return true
(defmethod operation-done-p ((o load-op) (c rpi-gpio))
  t)

;; Perform a compile operation
(defmethod perform ((o compile-op) (c rpi-gpio))

  ;; Check if the .so has been created already
  (unless (operation-done-p o c)

    ;; Not done, so add the output dir (*library-file-dir*)
    ;; to cffi's foreign library directories list
    (pushnew (namestring *library-file-dir*)
	     cffi:*foreign-library-directories* :test #'string=)

    ;; run a shell command to cd into the libgpio directory and
    ;; run make to build libgpio.so
    (unless
	(zerop
	 (run-shell-command "cd ~A; make" (namestring *library-file-dir*)))

      ;; Non-zero exit indicates an error
      (error 'operation-error :component c :operation o))))

;; Check if compilation is done for an rpi-gpio file type
(defmethod operation-done-p ((o compile-op) (c rpi-gpio))
  
  (or
   ;; If the file exists in /usr/lib/libgpio.so, don't bother
   (and (probe-file #p"/usr/lib/libgpio.so") t)
   
      (let ((lib-file-name (make-pathname :name (component-name c)
					  :type "so"
					  :defaults *library-file-dir*)))

	;; Check that the source file exists,
	;; and the .so exists,
	;; and that if the .so exists, it's newer than the source
	(and
	 (probe-file (component-pathname c))
	 (probe-file lib-file-name)
	 (> (file-write-date lib-file-name)
	    (file-write-date (component-pathname c)))))))

(asdf:defsystem #:rpi
  :description "Access the Raspberry Pi's GPIO pins from Common Lisp."
  :author "Jeremiah LaRocco <jeremiah.larocco@gmail.com>"
  :license "ISC"
  :depends-on (#:cffi)
  :serial t
  :components ((:file "package")
	       (:rpi-gpio "gpio")
               (:file "rpi")))

