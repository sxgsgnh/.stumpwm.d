(ql:quickload :swank)
(in-package :stumpwm)
(set-module-dir "/home/sgnh/.stumpwm.d/modules")

(run-shell-command "feh --bg-scale /usr/share/backgrounds/archlinux/archlinux-aftermath.jpg")
(run-shell-command "fcitx")
(run-shell-command "emacs --bg-daemon=stumpwm")
(run-shell-command "xmodmap /home/sgnh/.xmodmap")
(setf *window-format* "%n-%c")


(defmacro add-to-list (list emt)
  `(setf ,list (append ,list (list ,emt))))

(load-module "ttf-fonts")

(xft:cache-fonts)
(set-font (list  (make-instance 'xft:font
				:family "DejaVu Sans"
				:subfamily "Book"
				:size 14)
		 (make-instance 'xft:font
				:family "font-logos"
				:subfamily "logos"
				:size 14)
		 (make-instance 'xft:font
				:family "Font Awesome 5 Brands Regular"
				:subfamily "Regular"
				:size 14)
		 (make-instance 'xft:font
				:family "Font Awesome 5 Pro Regular"
				:subfamily "Regular"
				:size 14)
		 (make-instance 'xft:font
				:family "Font Awesome 5 Pro Solid"
				:subfamily "Solid"
				:size 10)))

(load-module "hostname")

(load "~/.stumpwm.d/mode-line.lisp")
(setf *mode-line-timeout* 60)
(setf *time-modeline-string* "%k:%M")
;; (setq *window-number-map* (concatenate 'string #(#\U2460 #\U2461 #\U2462 #\U2463
;; 						 #\U2464 #\U2465 #\U2466 #\U2467
;; 						 #\U2468 #\U2469)))

(setf *screen-mode-line-format* (list " ^f1^6"
				      (string #\Uf103)
				      "^* ^f0%h %W^>[^f3%V] ^f0^f4%I^f0 %B %d"))

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
(set-fg-color "gray")
(set-bg-color *mode-line-background-color*)
(set-msg-border-width 2)
(setf *message-window-padding* 10)
(set-win-bg-color "gray10")
(set-focus-color "yellow")

(set-unfocus-color "black")
;; (load-module :swm-emacs)
;; (swm-emacs:emacs-daemon-start)
(defcommand chrome () ()
  (run-or-raise "chromium" '(:class "chrome1")))

(defcommand llpp () ()
  (run-or-raise "llpp" '(:class "pdfview")))
(defcommand shutdown () ()
  (run-shell-command "shutdown -h now"))
(defcommand reboot () ()
  (run-shell-command "reboot"))
(defcommand term () ()
  (run-shell-command "xterm"))
(defcommand emacsnw () ()
  (run-shell-command "urxvt -e emacs -nw"))
(defcommand xx-net () ()
  (run-shell-command "sudo sh /home/sgnh/.local/XX-Net-3.12.11/xx_net.sh"))

(defcommand aaa (a)
    ((:function "fas:"))
  (format t "~a" a))

(setq *message-window-y-padding* 8)

;;(setq app-menu::*app-menu* `(("chrome" chrome)
;;			     (,(concat "^f4^3" (string #\Ue926) "^*^f0 Emacs") emacs)
;;			     (,(concat "^f4^2" (string #\Uf0c8) "^*^f0 Term") urxvt)
;;			     ("pdf" pdf)
;;			     ("xx-net" xx-net)))


(define-key *root-map* (kbd "u") "only")

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



(defcommand volume+ () ()
  (volume-control :add))

(defcommand volume- () ()
  (volume-control :dec))
(defcommand volume-toggle-mute () ()
  (if (volume-mute-p)
      (volume-control :unmute)
      (volume-control :mute)))
(define-key *top-map* (kbd "XF86MonBrightnessUp") "brightness 1")
(define-key *top-map* (kbd "XF86MonBrightnessDown") "brightness 0")
(define-key *top-map* (kbd "XF86AudioLowerVolume") "volume-")
(define-key *top-map* (kbd "XF86AudioRaiseVolume") "volume+")
(define-key *top-map* (kbd "XF86AudioMute") "volume-toggle-mute")
(define-key *top-map* (kbd "F12") "fullscreen")
(define-interactive-keymap toggle-window  ()
  ((kbd "j") "next")
  ((kbd "k") "prev"))

(define-remapped-keys '(("URxvt"
			 ("C-y" . ("M-p" "+")))
			("Chromium"
			 ("C-p" . "Up")
			 ("C-n" . "Down"))))

(defcommand auto-tile () ()
  (funcall *expose-auto-tile-fn* nil
	   (current-group (current-screen)))
  (run-commands "fselect"))

(defvar *start-menu-item* '(("emacs" . "emacs")
			    ("chrome" . "chrome")
			    ("xx-net" . "xx-net")
			    ("shutdown" . "shutdown")
			    ("reboot" . "reboot")))

(defcommand start-menu () ()
  (when *start-menu-item*
    (let* ((res (cdr (select-from-menu (current-screen) *start-menu-item*))))
      (run-commands res))))

(define-key *root-map* (kbd "m") "start-menu")

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

(run-shell-command "xcape")

