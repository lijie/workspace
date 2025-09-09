;; melpa
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/"))
;(when (< emacs-major-version 24)
;  ;; For important compatibility libraries like cl-lib
;  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(add-to-list 'package-archives
	     '("melpa-stable" . "http://stable.melpa.org/packages/") t)
(package-initialize)

;; install emacs package by using MELPA
;;(package-install 'helm)
(package-install 'google-this)
(package-install 'find-file-in-project)
(package-install 'lsp-mode)
(package-install 'lsp-ui)
(package-install 'go-mode)
;;(package-install 'helm-ag)
;;(package-install 'helm-gtags)
;;(package-install 'helm-swoop)
(package-install 'golden-ratio)
(package-install 'company)
(package-install 'projectile)
(package-install 'lsp-java)

(package-install 'vertico)
(package-install 'use-package)
(package-install 'orderless)
(package-install 'consult)
(package-install 'marginalia)
(package-install 'embark)
(package-install 'embark-consult)

(package-install 'color-theme-sanityinc-tomorrow)
(package-install 'doom-themes)
