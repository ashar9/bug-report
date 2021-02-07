# bug-report


Code generated as a side-effect of defmacro expansion is not consistent if the project is loaded again from cache (e.g. SBCL .fasl) by the compiler. If .fasl file is deleted, then works OK.

I know that the Lisp standard does not guarantee when a macro is expanded, but I assume it guarantees that however it expands, it will do the right thing.

Bug reproduction code is at https://github.com/ashar9/bug-report  (structured as a quicklisp project in local-projects directory)


Both EVAL and COMPILE have the same error with cache/fasl (both versions shown below)

How it is Run:
sbcl --eval '(quicklisp:quickload :bug-report)'

ERROR: 
1. Works OK when run the first time
2. Get undefined function CALLBACK--HELO subsequenty (i.e. loaded from fasl cache by SBCL)

WORKAROUND:
 Deleting the fasl file (or newer source timestamp) makes it work OK again
	rm  ~/.cache/common-lisp/sbcl-2.1.0-linux-x64/home/ec2-user/quicklisp/local-projects/bug-report/main.fasl



(in-package #:bug-report)

; to focus on the issue, the code does not show the threads, callback mechanisms, etc

```lisp
(defmacro split-processing (n) ; EVAL Version
  (let ((name (intern (format nil "CALLBACK--~A" n))))
    (eval `(defun ,name ()
             (format t "callback here:  ~A~%" ',name)))
    `(progn
       (format t "Process ~A~%" ,n)    ; do some front-end processing
       (,name)))) ;test the callback. supposed to be called from other threads in actual application

(defmacro split-processing2 (n) ; COMPILE version
  (let* ((name (intern (format nil "CALLBACK--~A" n))))
    (compile name  `(lambda ()
             (format t "compiled callback here:  ~A~%" ',name)))

    `(progn
       (format t "Process ~A~%" ,n)
       (,name))))   ;test the callback. supposed to be called from other threads in actual application

(split-processing "HELO")
(split-processing2 "WORD")
````


Motivation: macro split-processing (just a straw man example) is intended to be used in web pages or inner loops where (defun ...) of callbacks (defun not in toplevel) should not be called/compiled again and again (and hence created at compile time once). 

