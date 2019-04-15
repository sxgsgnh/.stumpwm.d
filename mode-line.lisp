(ql:quickload :clx-truetype)
(in-package :stumpwm)

(defvar *query-function* '())

(defvar *battery-levels* '(100 #\Uf240 75 #\Uf241 50 #\Uf242 25 #\Uf243 5 #\Uf244))
(defvar *battery-charging* nil)
(defvar *battery-capacity-character* (eval
				      (with-open-file (stream "/sys/class/power_supply/BAT0/capacity")
					(let* ((cap (read stream)))
					  (dolist (var '(5 25 50 75 100))
					    (when (<= cap var)
					      (return (getf *battery-levels* var))))))))

;; nowifi:#\Uf6ac full:#\Uf1eb middle:#\Uf6ab low:#\Uf6aa
(defvar *wifi-singal-character* #\Uf1eb)

;; vol1:#\Uf027 vol3:#\Uf028 vol2:#\Uf6a8 mute:#\Uf6a9 vol0:#\Uf026 novol: #\Uf2e2

(defun battery-charging ()
  (with-open-file (stream "/sys/class/power_supply/BAT0/status")
    (unless (eql *battery-charging*
		 (string= (read stream) "CHARGING"))
      (setf *battery-charging* (not *battery-charging*)) t)))

(defun battery-capacity ()
  (with-open-file (stream "/sys/class/power_supply/BAT0/capacity")
    (let* ((capacity-char (getf *battery-levels* (read stream))))
      (when capacity-char
	(unless (char= capacity-char *battery-capacity-character*)
	  (setf *battery-capacity-character* capacity-char) t)))))

(defun wifi-info ()
  (let ((dBm (ppcre:scan-to-strings "-\\d{2}"
				    (run-shell-command "cat /proc/net/wireless" t))))
    (if dBm
	(progn
	  (setf dBm (parse-integer dBm))
	  (cond ((>= dBm -50) (unless (char= *wifi-singal-character* #\Uf1eb)
				(setf *wifi-singal-character* #\Uf1eb) t))
		((and (<= dBm -51) (>= dBm -70)) (unless (char= *wifi-singal-character* #\Uf6ab)
						   (setf *wifi-singal-character* #\Uf6ab) t))
		((<= dBm -71) (unless (char= *wifi-singal-character* #\Uf6aa)
				(setf *wifi-singal-character* #\Uf6aa) t))))
	(unless (char=  *wifi-singal-character* #\Uf6ac)
	  (setf *wifi-singal-character* #\Uf6ac) t))))

(defun volume-mute-p ()
  (when (ppcre:all-matches
	 "\\[off\\]"
	 (run-shell-command "amixer sget Master" t)) t))
(defun volume-control (sym)
  (let (cmd )
    (case sym
      (:add (setf cmd "amixer set Master 12dB+"))
      (:dec (setf cmd "amixer set Master 12dB-"))
      (:mute (setf cmd "amixer sset Master mute"))
      (:unmute (setf cmd "amixer sset Master unmute")))
    (run-shell-command cmd)
    (update-all-mode-lines)))
;; vol1:#\Uf027 vol3:#\Uf028 vol2:#\Uf6a8 mute:#\Uf6a9 vol0:#\Uf026 novol: #\Uf2e2
(defun fmt-volume (ml)
  (format nil "~a^f0 ~a"
	  (if (volume-mute-p)
	      (string #\Uf6a9)
	      (string #\Uf028))
	  (ppcre:scan-to-strings "(?<=\\[)\\d*%(?=\\])"
	  			 (run-shell-command "amixer sget Master" t))
	  ))

(add-screen-mode-line-formatter #\V #'fmt-volume)

(defun fmt-battery (ml)
  (let ((value ))
    (format nil "^f3~a^f0 ^f4~a^f0" (string *battery-capacity-character*)
	    (if *battery-charging* (string #\Uf0e7) ""))))

(add-screen-mode-line-formatter #\B #'fmt-battery)

(defun fmt-wifi (ml)
  (string *wifi-singal-character*))

(add-screen-mode-line-formatter #\I #'fmt-wifi)
(defun update-data ()
  (dolist (var *query-function*)
    (when (funcall var)
      (update-all-mode-lines)
      (return-from update-data))))

(add-to-list *query-function* #'wifi-info)
(add-to-list *query-function* #'battery-charging)
(add-to-list *query-function* #'battery-capacity)


(run-with-timer 1 1 #'update-data)
