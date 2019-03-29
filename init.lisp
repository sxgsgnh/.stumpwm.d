(ql:quickload :swank)
(in-package :stumpwm)
(set-module-dir "/home/sgnh/.stumpwm.d/modules")

(run-shell-command "feh --bg-scale /usr/share/wallpapers/PastelHills/contents/images/1024x768.jpg")
;;(run-shell-command "xcompmgr -f")
(run-shell-command "fcitx")
(run-shell-command "emacs --bg-daemon=stumpwm")
(run-shell-command "xmodmap /home/sgnh/.xmodmap")
(run-shell-command "xcape")
;; (run-shell-command "sudo sh /home/sgnh/.local/XX-Net-3.12.11/xx_net.sh")

;; (load-module "swm-gaps")
;; (setf swm-gaps:*inner-gaps-size* 2)
;; (setf swm-gaps:*outer-gaps-size* 2)

(setf *window-format* "%n-%c")

(load-module "ttf-fonts")

(xft:cache-fonts)
(set-font (list (make-instance 'xft:font
			       :family "DejaVu Sans Mono"
			       :subfamily "Book"
			       :size 14)
		(make-instance 'xft:font
			       :family "stumpwm"
			       :subfamily "Regular"
			       :size 12)
		(make-instance 'xft:font
			       :family "YaHei Consolas Hybrid"
			       :subfamily "YaHei Consolas Hybrid Regular"
			       :size 12)))

(load-module "hostname")

(setf *mode-line-timeout* 30)
(setf *time-modeline-string* "%k:%M")
(setf *screen-mode-line-format* (list "%h %W^>"
				      " ^f1"
				      (string #\UE006)
				      "  ^f0%d"))

(setf *mode-line-background-color* "#2A3635")
(setf *mode-line-foreground-color* "gray80")
(setf *mode-line-pad-y* 1)
(setf *mode-line-pad-x* 1)
(setf *mode-line-border-color* "#2A3635")
(run-commands "mode-line")


(load-module "app-menu")

(setf *window-border-style* :thin)

(setf *normal-border-width* 1)

(setf *normal-gravity* :center)
(setf *maxsize-border-width* 1)
(setf *maxsize-gravity* :center)
(setf *transient-border-width* 1)
(setf *transient-gravity* :center)
(setf *input-window-gravity* :center)
(setf *message-window-gravity* :center)
(set-win-bg-color "black")
(set-focus-color "yellow")

(set-unfocus-color "black")
;; (load-module :swm-emacs)
;; (swm-emacs:emacs-daemon-start)
(defcommand chrome () ()
  (run-or-raise "chromium" '(:class "chrome1")))

(defcommand pdf () ()
  (run-or-raise "llpp" '(:class "pdfview")))
(defcommand shutdown () ()
  (run-shell-command "shutdown -h now"))
(defcommand reboot () ()
  (run-shell-command "reboot"))
(defcommand term () ()
  (run-shell-command "xterm"))
(defcommand emacsnw () ()
  (run-shell-command "urxvt -e emacs -nw"))

(setq *message-window-y-padding* 8)


(setq app-menu::*app-menu* '(("Chrome" chrome)
			     ("Term" urxvt)
			     ("pdf" pdf)))

(define-key *root-map* (kbd "m") "show-menu")

(define-key *root-map* (kbd "u") "remove-split")

(define-key *root-map* (kbd "w") "pull-from-windowlist")
;; (define-key *root-map* (kbd "e") "swm-emacs")
(define-key *root-map* (kbd "e") "emacs")
(define-key *root-map* (kbd "E") "emacsnw")
(define-key *root-map* (kbd "C") "term")
(define-key *root-map* (kbd "c") "run-shell-command 'urxvt'")

(defparameter *step* 2)

(defcommand brightness (a)
  ((:number "0 or 1:"))  
  (let* ((cur (parse-integer (run-shell-command "cat /sys/class/backlight/acpi_video0/brightness" t)))
	 (max-brign (parse-integer (run-shell-command "cat /sys/class/backlight/acpi_video0/max_brightness" t)))

	 (num (if (>= a 1)
		  (if (> (+ cur *step*) max-brign) max-brign
		      (+ cur *step*))
		  (if (< (- cur *step*) 0) 0
		      (- cur *step*)))))
    (run-shell-command (concat "echo "
			       (write-to-string num)
			       "| sudo tee /sys/class/backlight/acpi_video0/brightness"))
    ))



(defmacro add-to-list (list emt)
  `(setf ,list (append ,list (list ,emt))))

(define-key *top-map* (kbd "XF86MonBrightnessUp") "brightness 1")
(define-key *top-map* (kbd "XF86MonBrightnessDown") "brightness 0")
(define-key *top-map* (kbd "F12") "fullscreen")


(swank-loader:init)
(defcommand swank () ()
  (setf *top-level-error-action* :break)
  (swank:create-server :port 4005
		       :style swank:*communication-style*
		       :dont-close t)
  (echo-string
   (current-screen)
   "Starting swank. M-x slime-connect RET RET then (in-package :stumpwm)."))

(swank)

