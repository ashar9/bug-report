# bug-report
### _Your Name <your.name@example.com>_


Code generated as a side-effect of defmacro expansion is not consistent if the project is loaded again from cache (e.g. SBCL .fasl) by the compiler. If .fasl file is deleted, then works OK.

I know that the Lisp standard does not guarantee when a macro is expanded, but I assume it guarantees that however it expands, it will do the right thing (to use the quote from your book).
Just wanted your opinion, if the standard allows different behaviour by implementations based on if they are using pre-compiled cache vs fresh compilation - before filing a bug report with SBCL (using version 2.1.0 on Centos 7)

Sample code is at https://github.com/ashar9/bug-report

My original code used eval, but also tried the compile function, but that has the same effect.

I know that some purists are going to object based on "referential transparency" or something, but this approach is just too powerful to not use just because of some unwarranted ideals.

Get undefined function CALLBACK--HELO  etc when loaded from fasl cache by SBCL

(in-package #:bug-report)

; to focus on the issue, the code does not show the threads, callback mechanisms, etc

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


Motivation: macro split-processing (just a straw man example) is intended to be used in web pages or inner loops where (defun ...) of callbacks (defun not in toplevel) should not be called/compiled again and again (and hence created at compile time once). 

ERROR: 
undefined function CALLBACK--HELO  etc when loaded from cache by SBCL

Workaround:  delete the .fasl file in  ~/.cache/common-lisp/sbcl-2.1.0-linux-x64/home/ec2-user/quicklisp/local-projects/bug-report/main.fasl

Other workaround: Check at runtime if fboundp for the generated function, and compile once at runtime
(I used the following in my real application):


;ajax-gen-code is the code as `(lambda() (defun ,url-callback() .....))

...end of defmacro
(let ((fn-gen-ajax (gensym )))
                (compile fn-gen-ajax ajax-gen-code)  
                (funcall fn-gen-ajax))  ; run defun once   macro expansion time   
              `(unless *productionp*  ; for production always clear cache for project bfore loading
                 ; FOR SBCL reading evaled defun compilation from cache/fasl is not found
                 ; for production, clear cache before building the project using datatable
                 ; otherwise, check at the runtime if the function is not defined

                 (format t "We are in the webpage function~%")
                 (let ((ajax-handler-fn ',(handler-url2function url)))
                   (if (fboundp ajax-handler-fn)            ; runtime 
                     (format t "  DEFINED!!  ~A  __DEFINED___ @______@~%" ajax-handler-fn)
                     (progn
                     (format t "   MISSING  ~A  __MISSING |^^^^^^^^^^^| compile-now ~%" ajax-handler-fn)
                       ;(format t "Here is a recipe: ~A~%" ,ajax-gen-code)
                       (funcall ,ajax-gen-code)  ; compile code once at runtime

                       )
                     )))




