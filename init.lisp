(ql:quickload :swank)
(in-package :stumpwm)
(set-module-dir "/home/sgnh/.stumpwm.d/modules/stumpwm-contrib")

(run-shell-command "feh --bg-scale ~/Downloads/arch.jpg")
(run-shell-command "fcitx")
(run-shell-command "xmodmap /home/sgnh/.xmodmap")
(run-shell-command "mate-power-manager")

(load-module "swm-gaps")
(setf swm-gaps:*inner-gaps-size* 2)
(setf swm-gaps:*outer-gaps-size* 2)

(setf *window-format* "%m[%n]%s[ %i ]")

(load-module "ttf-fonts")
(xft:cache-fonts)
(set-font (make-instance 'xft:font :family "DejaVu Sans Mono" :subfamily "Book" :size 10))

(load-module "hostname");%h
(load-module "battery-portable");%B
(load-module "cpu");%c %C %t %f
(load-module "wifi")
(load-module "mem")
(setf *screen-mode-line-format* "[%h][%c|^0%M|wifi:%I|%B]%w")
(setf *mode-line-background-color* "#2A3635")
(setf *mode-line-foreground-color* "gray80")
(setf *mode-line-pad-y* 1)
(setf *mode-line-pad-x* 1)
(setf *mode-line-border-color* "#2A3635")
(run-commands "mode-line")


(setf *window-border-style* :thin)
(setf *normal-border-width* 1)
(setf *normal-gravity* :center)
(setf *maxsize-border-width* 1)
(setf *maxsize-gravity* :center)
(setf *transient-border-width* 1)
(setf *transient-gravity* :center)
(setf *input-window-gravity* :center)
(setf *message-window-gravity* :center)

(set-win-bg-color "#2A3635")
(set-focus-color "red")
(set-unfocus-color "#2A3635")

(load-module :swm-emacs)
(swm-emacs:emacs-daemon-start)

(defcommand chrome () ()
	    (run-or-raise "chromium" '(:class "chrome1")))
(defcommand shutdown () ()
  (run-shell-command "shutdown -h now"))
(defcommand term () ()
  (run-shell-command "mate-terminal"))
(defcommand reserver () ()
  (swm-emacs:emacs-daemon-stop)
  (swm-emacs:emacs-daemon-start))

(define-key *root-map* (kbd "u") "remove-split")
(define-key *root-map* (kbd "F12") "fullscreen")
(define-key *root-map* (kbd "w") "pull-from-windowlist")
(define-key *root-map* (kbd "e") "swm-emacs")
(define-key *root-map* (kbd "E") "emacs")
(define-key *root-map* (kbd "c") "term")


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

