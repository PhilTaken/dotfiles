;;; package --- Summary
;;; config for my doom emacs

;;; Commentary:
;;

;;; Code:

(setq doom-font (font-spec :family "Iosevka Comfy" :size 16))
(setq lsp-rust-server 'rust-analyzer)

(use-package autothemer
  :ensure t)

(load-theme 'catppuccin-mocha t)
