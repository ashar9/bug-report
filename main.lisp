
(in-package #:bug-report)



(defmacro split-processing (n)
  (let ((name (intern (format nil "CALLBACK--~A" n)))) 
    (eval `(defun ,name ()
             (format t "callback here:  ~A~%" ',name)))  
    `(progn
       (format t "Process ~A~%" ,n)
       (,name))))

(defmacro split-processing2 (n)
  (let* ((name (intern (format nil "CALLBACK--~A" n)))) 
    (compile name  `(lambda ()
             (format t "compiled callback here:  ~A~%" ',name)))  

    `(progn
       (format t "Process ~A~%" ,n)
       (,name))))





(split-processing "HELO") 
(split-processing2 "WORD") 
(split-processing2 "X") 

;(CALLBACK--x)

(defun symb (&rest args)
  (values (intern (apply #'mkstr args))))


(defun mkstr (&rest args)
  (with-output-to-string (s)
    (dolist (a args) (princ a s))))

(apply #'mkstr (list 'a 'b 10 :heloup "WHAT"))
(symb 'a 'b 10 :heloup "WHAT")
(symb '@ "hello" "dear")




