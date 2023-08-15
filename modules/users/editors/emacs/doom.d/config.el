;;; package --- Summary
;;; config for my doom emacs

;;; Commentary:
;;

;;; Code:

(setq doom-font (font-spec :family "Iosevka Comfy" :size 16))
(setq lsp-rust-server 'rust-analyzer)

(use-package autothemer :ensure t)
(use-package parinfer-rust-mode :ensure t)
(use-package janet-mode :ensure t)

(load-theme 'catppuccin-mocha t)
