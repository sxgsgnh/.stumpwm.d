(in-package :stumpwm)

(defvar *mode-line-widgets* ())

(defvar *mode-line-icon-font* nil)


(defun add-widgets-functions (function )
  (setf *mode-line-widgets*
	(append *mode-line-widgets* (list function))))

(defun draw-mode-line (ml)
  (let* ((drawable (mode-line-window ml))
	 (gc (mode-line-gc ml))
	 (width (xlib:drawable-width drawable))
	 (height 4))
    (dolist (widget *mode-line-widgets*)
      (multiple-value-bind (string font lp rp) (funcall widget)
	(setf width (- width (+ lp rp)))
	(xft:draw-text drawable gc font string
		       (+ (decf width
				(xft:text-width drawable font string))
			  lp)
		       (+ height (xft:font-ascent drawable font))
		       :draw-background-p t)
	(setf (xft:font-overwrite-gcontext font) nil)))))

(defun widget-time ()
  (values (time-format *time-modeline-string*) *mode-line-icon-font* 2 2))

(defun test ()
  (values (string #\Ue006) *mode-line-icon-font* 2 2))
(defun test2 ()
  (values (string #\Ue00c) *mode-line-icon-font* 5 10))

(xft:cache-font-file "~/.stumpwm.d/modeline.ttf")
(setf *mode-line-icon-font* (make-instance 'xft:font :family "stumpwm" :subfamily "Regular" :size 14))
