;;; catppuccin-mocha-theme.el --- Catppuccin Theme

;; Copyright 2015-present, All rights reserved
;;
;; SPDX-License-Identifier: MIT

;; Maintainer: Name <namesexistsinemails@gmail.com>
;; Author: Mikael Konradsson, Name
;; Version: 2.0.0
;; Package-Requires: ((emacs "25.1")(autothemer "0.2"))
;; URL: https://github.com/catppuccin/emacs

;;; Commentary:

;; A sweet color theme available for a number of editors.

;;; Code:
(eval-when-compile
  (require 'cl-lib))

(require 'autothemer)

(unless (>= emacs-major-version 24)
  (error "Requires Emacs 24 or later"))


(autothemer-deftheme
 catppuccin-mocha "A theme based on catppuccin's amazing color scheme"

 ((((class color) (min-colors #xFFFFFF))        ; col 1 GUI/24bit
   ((class color) (min-colors #xFF)))           ; col 2 Xterm/256

  ;; Define our color palette

  (rosewater  "#f5e0dc" "#ffffff")
  (flamingo   "#f2cdcd" "#ffd7df")
  (pink       "#f5c2e7" "#d7afaf")
  (mauve      "#cba6f7" "#d7afd7")
  (red        "#f38ba8" "#ff87af")
  (maroon     "#eba0ac" "#ffafaf")
  (peach      "#fab387" "#ffaf87")
  (yellow     "#f9e2af" "#ffd7af")
  (green      "#a6e3a1" "#87afaf")
  (teal       "#94e2d5" "#afd7d7")
  (sky        "#89dceb" "#afffff")
  (sapphire   "#74c7ec" "#afffff")
  (blue       "#89b4fa" "#00d7ff")
  (lavender   "#b4befe" "#d7d7ff")
  (text       "#cdd6f4" "#ffffff")
  (subtext1   "#bac2de" "#ffffff")
  (subtext0   "#a6adc8" "#ffffff")
  (overlay2   "#9399b2" "#ffffff")
  (overlay1   "#7f849c" "#ffffff")
  (overlay0   "#6c7086" "#ffffff")
  (surface2   "#585b70" "#ffffff")
  (surface1   "#45475a" "#ffffff")
  (surface0   "#313244" "#ffffff")
  (base       "#1e1e2e" "#ffffff")
  (mantle     "#181825" "#ffffff")
  (crust      "#11111b" "#ffffff"))

 ;; Customize faces
 (
  (default                              (:foreground text :background base))
  (border                               (:background base :foreground base))
  (bookmark-face                        (:foreground red :background base))
  (button                               (:foreground green))
  (child-frame                          (:background base :foreground mantle))
  (child-frame-border                   (:background base :foreground mantle))
  (cursor                               (:background mauve :foreground base))
  (error                                (:foreground red))
  (fringe                               (:background base :foreground overlay2))
  (glyph-face                           (:background red))
  (escape-glyph                         (:foreground overlay1 :italic t))
  (glyphless-char                       (:foreground overlay2))
  (header-line                          (:background base))
  (highlight                            (:background surface1 :foreground lavender))
  (hl-line                              (:background surface0))
  (homoglyph                            (:foreground teal))
  (internal-border                      (:background base :foreground base))
  (line-number                          (:foreground surface1 :background nil))
  (line-number-current-line             (:foreground mauve :background surface0 :bold t))
  (lv-separator                         (:foreground overlay2 :background base))
  (match                                (:background yellow :foreground crust))
  (menu                                 (:background base :foreground rosewater))
  (fill-column-indicator                (:foreground surface0))
  (mode-line                            (:background mantle))
  (mode-line-inactive                   (:background base :foreground subtext1 :bold nil))
  (mode-line-active                     (:background mantle :foreground subtext0 :bold t))
  (mode-line-highlight                  (:foreground flamingo))
  (mode-line-buffer-id                  (:foreground green :bold t))
  (numbers                              (:background green :foreground base))
  (region                               (:background text :distant-foreground base))
  (separator-line                       (:background base))
  (shadow                               (:background crust))
  (success                              (:foreground green))
  (vertical-border                      (:foreground surface0 :background nil))
  (warning                              (:foreground yellow))
  (window-border                        (:foreground peach))
  (window-divider                       (:foreground surface0))

  ;; font lock
  (font-lock-type-face                  (:foreground lavender))
  (font-lock-regexp-grouping-backslash  (:foreground yellow))
  (font-lock-keyword-face               (:bold t :foreground maroon))
  (font-lock-warning-face               (:inherit 'warning))
  (font-lock-constant-face              (:foreground lavender))
  (font-lock-string-face                (:foreground green :italic t))
  (font-lock-builtin-face               (:foreground yellow))
  (font-lock-reference-face             (:foreground sky))
  (font-lock-constant-face              (:foreground flamingo))
  (font-lock-function-name-face         (:foreground blue))
  (font-lock-variable-name-face         (:foreground mauve))
  (font-lock-negation-char-face         (:foreground red))
  (font-lock-comment-face               (:foreground overlay1 :italic t))
  (font-lock-comment-delimiter-face     (:foreground overlay2 :italic t))
  (font-lock-doc-face                   (:foreground overlay2))
  (font-lock-doc-markup-face            (:foreground overlay2))
  (font-lock-preprocessor-face          (:foreground overlay2))
  (elisp-shorthand-font-lock-face       (:foreground peach))

  (highlight-operators-face             (:foreground red))
  (highlight-quoted-symbol              (:foreground maroon))
  (highlight-numbers-face               (:foreground pink))
  (highlight-symbol-face                (:background mantle :foreground green :weight 'semi-bold))
  (info-xref                            (:foreground yellow))

  (minibuffer-prompt-end                (:foreground red))
  (minibuffer-prompt                    (:foreground mauve))
  (epa-mark                             (:foreground pink))
  (dired-mark                           (:foreground pink))

  (trailing-rosewaterspace              (:background surface1))

  ;; battery colors
  (doom-modeline-battery-critical       (:inherit 'error))
  (doom-modeline-battery-warning        (:inherit 'warning))
  (doom-modeline-battery-charging       (:foreground overlay2))
  (doom-modeline-battery-error          (:inherit 'eror))
  (doom-modeline-battery-normal         (:foreground overlay2))
  (doom-modeline-battery-full           (:foreground overlay1))

  ;; doom visual state
  (doom-modeline-evil-motion-state      (:foreground teal))
  (doom-modeline-evil-emacs-state       (:foreground blue))
  (doom-modeline-evil-insert-state      (:foreground mauve))
  (doom-modeline-evil-normal-state      (:foreground text))
  (doom-modeline-evil-visual-state      (:foreground sky))
  (doom-modeline-evil-replace-state     (:foreground red))
  (doom-modeline-evil-operator-state    (:foreground blue))

  (doom-modeline-project-dir            (:foreground overlay2))
  (doom-modeline-buffer-path            (:foreground overlay2))
  (doom-modeline-buffer-file            (:foreground subtext1 :bold t))
  (doom-modeline-buffer-major-mode      (:foreground peach :bold t))
  (doom-modeline-buffer-modified        (:foreground overlay2 :italic t :bold t))
  (doom-modeline-error                  (:background red))
  (doom-modeline-info                   (:foreground overlay2))
  (doom-modeline-project-dir            (:foreground peach))
  (doom-modeline-bar                    (:background lavender :foreground crust))
  (doom-modeline-panel                  (:inherit 'bold :background flamingo :foreground mantle))
  (doom-modeline                        (:foreground overlay1))
  (doom-themes-visual-bell              (:background red))

  ;; elfeed
  (elfeed-search-feed-face              (:foreground lavender))
  (elfeed-search-tag-face               (:foreground green))

  ;; ediff
  (ediff-even-diff-A                    (:background crust))
  (ediff-even-diff-B                    (:background crust))
  (ediff-even-diff-C                    (:background crust))
  (ediff-even-diff-Ancestor             (:background crust))
  (ediff-odd-diff-A                     (:inherit 'ediff-odd-diff-A))
  (ediff-odd-diff-B                     (:inherit 'ediff-odd-diff-B))
  (ediff-odd-diff-C                     (:inherit 'ediff-odd-diff-C))
  (ediff-odd-diff-Ancestor              (:inherit 'ediff-even-diff-Ancestor))

  ;; message colors
  (message-header-name                  (:foreground overlay2))
  (message-header-other                 (:foreground peach))
  (message-header-subject               (:foreground yellow))
  (message-header-to                    (:foreground rosewater))
  (message-header-cc                    (:foreground green))
  (message-header-xheader               (:foreground rosewater))
  (custom-link                          (:foreground blue))
  (link                                 (:foreground blue))

  ;; org-mode
  (org-done                             (:foreground overlay2))
  (org-code                             (:background crust))
  (org-meta-line                        (:background base :foreground blue))
  (org-block                            (:background base))
  (org-block-begin-line                 (:background base :foreground overlay2))
  (org-block-end-line                   (:background base :foreground overlay2))
  (org-headline-done                    (:foreground overlay2 :strike-through t))
  (org-todo                             (:foreground green :bold t))
  (org-headline-todo                    (:foreground base))
  (org-upcoming-deadline                (:foreground red))
  (org-footnote                         (:foreground green))
  (org-indent                           (:background base :foreground base))
  (org-hide                             (:background base :foreground base))
  (org-date                             (:foreground overlay2))
  (org-ellipsis                         (:foreground overlay2 :bold t))
  (org-level-1                          (:foreground red :height 1.3 :bold t))
  (org-level-2                          (:foreground mauve :height 1.15 :bold t))
  (org-level-3                          (:foreground flamingo :height 1.05))
  (org-level-4                          (:foreground text))
  (org-level-5                          (:foreground text))
  (org-level-6                          (:foreground yellow))
  (org-level-7                          (:foreground peach))
  (org-level-8                          (:foreground maroon))

  ;; dired
  (dired-directory  (:foreground yellow))
  (dired-ignored    (:foreground overlay1))
  (dired-flagged    (:foreground red))
  (dired-header     (:foreground blue :bold t))
  (dired-mark       (:foreground peach :bold t))
  (dired-marked     (:foreground pink :bold t :inverse-video t))
  (dired-perm-write (:foreground text :underline t))
  (dired-symlink    (:foreground sky :bold t))
  (dired-warning    (:foreground yellow))
    ;;;; dired+)
  (diredp-file-name              (:foreground subtext1))
  (diredp-dir-name               (:foreground subtext1 :bold t))
  (diredp-ignored-file-name      (:foreground overlay1))
  (diredp-compressed-file-suffix (:foreground overlay1))
  (diredp-symlink                (:foreground mauve))
  (diredp-dir-heading            (:foreground blue  :bold t))
  (diredp-file-suffix            (:foreground mauve))
  (diredp-read-priv              (:foreground pink))
  (diredp-write-priv             (:foreground green))
  (diredp-exec-priv              (:foreground yellow))
  (diredp-rare-priv              (:foreground red   :bold t))
  (diredp-dir-priv               (:foreground blue  :bold t))
  (diredp-no-priv                (:foreground overlay1))
  (diredp-number                 (:foreground pink))
  (diredp-date-time              (:foreground blue))
  ;; dired-k
  (dired-k-modified (:foreground sapphire :bold t))
  (dired-k-commited (:foreground green :bold t))
  (dired-k-added (:foreground green :bold t))
  (dired-k-untracked (:foreground sky :bold t))
  (dired-k-ignored (:foreground overlay1 :bold t))
  (dired-k-directory (:foreground blue :bold t))
  ;; dired-subtree
  (dired-subtree-depth-1-face (:background base) )
  (dired-subtree-depth-2-face (:background surface0))
  (dired-subtree-depth-3-face (:background surface1))
  (dired-subtree-depth-4-face (:background surface2))
  (dired-subtree-depth-5-face (:background overlay0))
  (dired-subtree-depth-6-face (:background overlay1))
  ;; diredfl
  (diredfl-autofile-name          (:foreground overlay1))
  (diredfl-compressed-file-name   (:foreground yellow))
  (diredfl-compressed-file-suffix (:foreground peach))
  (diredfl-date-time              (:foreground sky :weight 'light))
  (diredfl-deletion               (:foreground red :bold t))
  (diredfl-deletion-file-name     (:foreground red))
  (diredfl-dir-heading            (:foreground blue :bold t))
  (diredfl-dir-name               (:foreground blue))
  (diredfl-dir-priv               (:foreground blue))
  (diredfl-exec-priv              (:foreground green))
  (diredfl-executable-tag         (:foreground green))
  (diredfl-file-name              (:foreground text))
  (diredfl-file-suffix            (:foreground text))
  (diredfl-flag-mark              (:foreground yellow :bold t))
  (diredfl-flag-mark-line         (:background surface0))
  (diredfl-ignored-file-name      (:foreground overlay1))
  (diredfl-link-priv              (:foreground mauve))
  (diredfl-no-priv                ((:inherit 'shadow)))
  (diredfl-number                 (:foreground peach))
  (diredfl-other-priv             (:foreground pink))
  (diredfl-rare-priv              (:foreground text))
  (diredfl-read-priv              (:foreground yellow))
  (diredfl-symlink                (:foreground mauve))
  (diredfl-tagged-autofile-name   (:foreground overlay1))
  (diredfl-write-priv             (:foreground red))

  ;; magit
  (magit-bisect-bad        (:foreground red))
  (magit-bisect-good       (:foreground green))
  (magit-bisect-skip       (:foreground peach))
  (magit-blame-hash        (:foreground sky))
  (magit-blame-date        (:foreground red))
  (magit-blame-heading     (:foreground peach :background surface0 :extend t))
  (magit-branch-current    (:foreground blue))
  (magit-branch-local      (:foreground sky))
  (magit-branch-remote     (:foreground green))
  (magit-cherry-equivalent (:foreground mauve))
  (magit-cherry-unmatched  (:foreground sky))
  (magit-diff-added             (:foreground green  :background base))
  (magit-diff-added-highlight   (:foreground green                    :background base :bold t :extend t))
  (magit-diff-base              (:foreground  peach  :background crust :extend t))
  (magit-diff-base-highlight    (:foreground peach                   :background crust :bold t :extend t))
  (magit-diff-context           (:foreground text :background base :extend t))
  (magit-diff-context-highlight (:foreground text                   :background crust :extend t))
  (magit-diff-file-heading           (:foreground text :bold t :extend t))
  (magit-diff-file-heading-selection (:foreground pink               :background blue :bold t :extend t))
  (magit-diff-hunk-heading           (:foreground base                    :background  mauve :extend t))
  (magit-diff-hunk-heading-highlight (:foreground base                    :background mauve :bold t :extend t))
  (magit-diff-lines-heading          (:foreground yellow :background red :extend t :extend t))
  (magit-diff-removed                (:foreground red :background mantle  :extend t))
  (magit-diff-removed-highlight      (:foreground red                   :background surface0 :bold t :extend t))
  (magit-diff-whitespace-warning     (:foreground red))
  (magit-diffstat-added              (:foreground green))
  (magit-diffstat-removed            (:foreground red))
  (magit-dimmed (:foreground overlay1))
  (magit-hash (:foreground overlay1))
  (magit-header-line (:background surface0 :foreground text :bold t)
                     :box `(:line-width 3 :color ,blue))
  (magit-filename (:foreground mauve))
  (magit-log-author (:foreground peach))
  (magit-log-date (:foreground blue))
  (magit-log-graph (:foreground overlay1))
  (magit-process-ng (:forground red))
  (magit-process-ok (:foreground green))
  (magit-reflog-amend (:foreground mauve))
  (magit-reflog-checkout (:foreground blue))
  (magit-reflog-cherry-pick (:foreground green))
  (magit-reflog-commit (:foreground green))
  (magit-reflog-merge (:foreground green))
  (magit-reflog-other (:foreground sky))
  (magit-reflog-rebase (:foreground mauve))
  (magit-reflog-remote (:foreground sky))
  (magit-reflog-reset (:forground red))
  (magit-refname (:foreground overlay1))
  (magit-section-heading (:foreground blue :bold t :extend t))
  (magit-section-heading-selection (:foreground peach :bold t :extend t))
  (magit-section-highlight (:background surface0))
  (magit-section-secondary-heading (:foreground mauve :bold t :extend t))
  (magit-sequence-drop (:foreground red))
  (magit-sequence-head (:foreground blue))
  (magit-sequence-part (:foreground peach))
  (magit-sequence-stop (:foreground green))
  (magit-signature-bad (:foreground red))
  (magit-signature-error (:foreground red))
  (magit-signature-expired (:foreground peach))
  (magit-signature-good (:foreground green))
  (magit-signature-revoked (:foreground mauve))
  (magit-signature-untrusted (:foreground yellow))
  (magit-tag (:foreground yellow))

  ;; which-key
  (which-key-key-face                   (:inherit 'font-lock-variable-name-face))
  (which-func                           (:inherit 'font-lock-function-name-face :bold t))
  (which-key-group-description-face     (:foreground pink))
  (which-key-command-description-face   (:foreground blue))
  (which-key-local-map-description-face (:foreground yellow))
  (which-key-posframe                   (:background crust))
  (which-key-posframe-border            (:background crust))

  ;; swiper
  (swiper-line-face                     (:foreground yellow))
  (swiper-background-match-face-1       (:background peach :foreground crust))
  (swiper-background-match-face-2       (:background blue :foreground crust))
  (swiper-background-match-face-3       (:background flamingo :foreground crust))
  (swiper-background-match-face-4       (:background red :foreground crust))
  (swiper-match-face-1                  (:inherit 'swiper-background-match-face-1))
  (swiper-match-face-2                  (:inherit 'swiper-background-match-face-2))
  (swiper-match-face-3                  (:inherit 'swiper-background-match-face-3))
  (swiper-match-face-4                  (:inherit 'swiper-background-match-face-4))

  (counsel-outline-default              (:foreground yellow))
  (info-header-xref                     (:foreground yellow))
  (xref-file-header                     (:foreground yellow))
  (xref-match                           (:foreground peach))

  ;; rainbow delimiter
  (rainbow-delimiters-mismatched-face   (:foreground red :background yellow))
  (rainbow-delimiters-unmatched-face    (:foreground green :background yellow))
  (rainbow-delimiters-base-error-face   (:foreground red :background yellow))
  (rainbow-delimiters-base-face         (:foreground overlay2))
  (rainbow-delimiters-depth-1-face      (:foreground text))
  (rainbow-delimiters-depth-2-face      (:foreground red))
  (rainbow-delimiters-depth-3-face      (:foreground blue))
  (rainbow-delimiters-depth-4-face      (:foreground yellow))
  (rainbow-delimiters-depth-5-face      (:foreground green))
  (rainbow-delimiters-depth-6-face      (:foreground mauve))
  (rainbow-delimiters-depth-7-face      (:foreground peach))
  (rainbow-delimiters-depth-8-face      (:foreground flamingo))
  (rainbow-delimiters-depth-9-face      (:foreground teal))

  ;; show-paren
  (show-paren-match                     (:background red :foreground crust :bold t))
  (show-paren-match-expression          (:background red :foreground crust :bold t))
  (show-paren-mismatch                  (:background red :foreground crust))

  (company-tooltip                      (:background crust :foreground overlay2))
  (company-tooltip-common               (:foreground red :distant-foreground red :bold t))
  (company-tooltip-search               (:background peach))
  (company-tooltip-selection            (:background surface1 :foreground text :distant-foreground text :bold t))
  (company-tooltip-mouse                (:background nil :foreground crust :distant-foreground text))
  (company-tooltip-annotation           (:foreground green))
  (company-tooltip-scrollbar-track      (:background peach))
  (company-tooltip-scrollbar-thumb      (:background flamingo))
  (company-tooltip-quick-access         (:foreground blue :distant-foreground surface1))
  (company-scrollbar-bg                 (:inherit 'tooltip))
  (company-scrollbar-fg                 (:background red))
  (company-preview                      (:foreground blue))
  (company-preview-common               (:background red :foreground crust))
  (company-preview-search               (:inherit 'company-tooltip-search))
  (company-template-field               (:inherit 'match))

  (company-box-annotation               (:foreground red :background surface1))
  (company-box-numbers                  (:foreground blue :background surface1))

  ;; eldoc
  (eldoc-box-body                       (:background surface0 :foreground peach))
  (eldoc-box-border                     (:background nil :foreground nil))

  (markdown-hr-face                     (:background nil :foreground surface0))

  ;; flycheck
  (flycheck-posframe-background-face    (:background crust))
  (flycheck-posframe-face               (:background crust))
  (flycheck-posframe-info-face          (:background crust :inherit 'info))
  (flycheck-posframe-warning-face       (:background crust :inherit 'warning))
  (flycheck-posframe-error-face         (:background crust :inherit 'error))
  (flycheck-fringe-warning              (:inherit 'warning))
  (flycheck-fringe-error                (:inherit 'error))
  (flycheck-fringe-info                 (:inherit 'info ))
  (flycheck-error-list-warning          (:inherit 'warning :bold t))
  (flycheck-error-list-error            (:inheirt 'error :bold t))
  (flycheck-error-list-info             (:inherit 'info :bold t))
  (flycheck-inline-error                (:foreground "black" :background red :height 128))
  (flycheck-inline-info                 (:foreground "black" :background blue :height 128))
  (flycheck-inline-warning              (:foreground "black" :background yellow :height 128))

  ;; indent dots
  (highlight-indent-guides-character-face       (:foreground surface0))
  (highlight-indent-guides-stack-character-face (:foreground surface0))
  (highlight-indent-guides-stack-odd-face       (:foreground surface0))
  (highlight-indent-guides-stack-even-face      (:foreground surface1))
  (highlight-indent-guides-stack-character-face (:foreground surface0))
  (highlight-indent-guides-even-face            (:foreground surface0))
  (highlight-indent-guides-odd-face             (:foreground surface1))

  ;; ido
  (ido-incomplete-regexp                        (:inherit 'error))
  (ido-indicator                                (:foreground blue))
  (ido-only-match                               (:foreground peach))
  (ido-subdir                                   (:foreground blue))
  (ido-virtual                                  (:foreground yellow))

  ;; ivy
  (ivy-current-match                            (:background blue :foreground crust :bold t))
  (ivy-action                                   (:background nil :foreground lavender))
  (ivy-grep-line-number                         (:background nil :foreground peach))
  (ivy-minibuffer-match-face-1                  (:background nil :foreground blue :bold t))
  (ivy-minibuffer-match-face-2                  (:background nil :foreground green))
  (ivy-minibuffer-match-highlight               (:foreground blue))
  (ivy-grep-info                                (:foreground blue))
  (ivy-grep-line-number                         (:foreground mauve))
  (ivy-confirm-face                             (:foreground green))

  ;; posframe's
  (ivy-posframe                                 (:background surface2))
  (ivy-posframe-border                          (:inherit 'ivy-posframe))

  (vertico-multiline                            (:background red))
  (vertico-group-title                          (:foreground subtext0 :bold t))
  (vertico-group-separator                      (:foreground overlay1 :strike-through t))
  (vertico-current                              (:foreground text :bold t :background crust :distant-background overlay1))

  (vertico-posframe-border                      (:background surface1))
  (vertico-posframe                             (:background surface0 :foreground text))

  (orderless-match-face-0                       (:foreground peach :bold t))
  (orderless-match-face-1                       (:foreground pink :bold t))
  (orderless-match-face-2                       (:foreground green :bold t))
  (orderless-match-face-4                       (:foreground yellow :bold t))

  (comint-highlight-prompt                      (:background peach :foreground crust))

  (completions-annotations                      (:foreground text :italic t))

  (treemacs-directory-collapsed-face            (:foreground text))
  (treemacs-directory-face                      (:foreground text))
  (treemacs-file-face                           (:foreground text))

  (treemacs-git-added-face                      (:foreground peach))
  (treemacs-git-renamed-face                    (:foreground rosewater))
  (treemacs-git-ignored-face                    (:foreground overlay2))
  (treemacs-git-unmodified-face                 (:foreground text))
  (treemacs-git-renamed-face                    (:foreground text))
  (treemacs-git-modified-face                   (:foreground maroon))

  ;; lets support solaire mode
  (solaire-default-face                         (:background mantle))

  ;; lsp
  (lsp-headerline-breadcrumb-path-error-face (:underline (:color maroon :style 'wave)
                                                         :foreground overlay2 :background base))

  (lsp-headerline-breadcrumb-path-face				(:background base))
  (lsp-headerline-breadcrumb-path-hint-face	   		(:background base))
  (lsp-headerline-breadcrumb-path-info-face	   		(:background base))
  (lsp-headerline-breadcrumb-separator-face			(:background base))
  (lsp-headerline-breadcrumb-symbols-face			(:background base))
  (lsp-headerline-breadcrumb-project-prefix-face	(:background base))
  (lsp-headerline-breadcrumb-symbols-error-face     (:foreground red))

  (lsp-ui-doc-background							(:background crust :foreground red))
  (lsp-ui-doc-header								(:background crust :foreground red))
  (lsp-ui-doc-border								(:background nil :foreground nil))
  (lsp-ui-peek-filename								(:foreground teal))
  (lsp-ui-sideline-code-action			   			(:foreground yellow))
  (lsp-ui-sideline-current-symbol					(:foreground sky))
  (lsp-ui-sideline-symbol							(:foreground overlay1))

  ;; dashboard
  (dashboard-heading                             (:foreground mauve :bold t))
  (dashboard-items-face                          (:bold nil :foreground text))
  (dashboard-banner-logo-title                   (:bold t :height 200))
  (dashboard-no-items-face                       (:foreground overlay2))

  ;; all-the-icons
  (all-the-icons-dgreen                          (:foreground green))
  (all-the-icons-green                           (:foreground green))
  (all-the-icons-dpurple                         (:foreground mauve))
  (all-the-icons-purple                          (:foreground mauve))

  ;; evil
  (evil-ex-lazy-highlight                        (:foreground yellow :bold t))
  (evil-ex-substitute-matches                    (:foreground red :strike-through t))
  (evil-ex-substitute-replacement                (:foreground blue :bold t))
  (evil-search-highlight-persist-highlight-face  (:background yellow))
  (evil-quickscope-first-face                    (:foreground yellow :underline t))
  (evil-quickscope-second-face                   (:foreground peach :underline t))
  (evil-goggles-default-face                     (:background nil))

  (ansi-color-crust                              (:background crust))

  (term                                          (:background crust :foreground text))
  (term-color-blue                               (:background blue :foreground blue))
  (term-color-bright-blue                        (:inherit 'term-color-blue))
  (term-color-red                                (:background red :foreground red))
  (term-color-bright-red                         (:background maroon :foreground maroon))
  (term-color-yellow                             (:background yellow :foreground yellow))
  (term-color-bright-yellow                      (:background yellow :foreground yellow))

  (term-color-green                              (:background green :foreground green))
  (term-color-bright-green                       (:inherit 'term-color-green))

  (term-color-bright-crust                       (:background mantle :foreground red))
  (term-color-rosewater                          (:background text :foreground text))
  (term-color-bright-rosewater                   (:background rosewater :foreground rosewater))
  (term-color-cyan                               (:background sky :foreground sky))
  (term-color-bright-cyan                        (:background sky :foreground sky))
  (term-color-magenta                            (:background mauve :foreground mauve))
  (term-color-bright-magenta                     (:background mauve :foreground mauve))
  (term-underline                                (:background mauve :foreground blue))

  (vterm-color-crust                             (:background mantle :foreground mantle))
  (vterm-color-blue                              (:background blue :foreground blue))
  (vterm-color-cyan                              (:background sky :foreground sky))
  (vterm-color-green                             (:background green :foreground green))
  (vterm-color-magenta                           (:background maroon :foreground maroon))
  (vterm-color-yellow                            (:background peach :foreground yellow))
  (vterm-color-red                               (:background red :foreground red))
  (vterm-color-rosewater                         (:background text :foreground text))

  (popup-face                                    (:inherit 'tooltip))
  (popup-selection-face                          (:inherit 'tooltip))
  (popup-tip-face                                (:inherit 'tooltip))

  (anzu-match-1                                  (:foreground green :background crust))
  (anzu-match-2                                  (:foreground yellow :background crust))
  (anzu-match-3                                  (:foreground teal :background crust))

  (anzu-mode-line                                (:foreground crust :background mauve))
  (anzu-mode-no-match                            (:foreground text :background red))
  (anzu-replace-to                               (:foreground yellow :background surface2))

  (ace-jump-face-background                      (:foreground overlay2))
  (ace-jump-face-foreground                      (:foreground red :background crust :bold t))

  (hydra-face-amaranth                           (:foreground mauve))
  (hydra-face-blue                               (:foreground blue))
  (hydra-face-pink                               (:foreground pink))
  (hydra-face-red                                (:foreground red))
  (hydra-face-teal                               (:foreground teal))

  ;; bookmarks
  (bm-fringe-face                                (:background red :foreground crust))
  (bm-fringe-persistent-face                     (:background red :foreground crust))

  (centaur-tabs-active-bar-face                  (:background crust :foreground text))
  (centaur-tabs-selected                         (:background crust :foreground text :bold t))
  (centaur-tabs-selected-modified                (:background crust :foreground text))
  (centaur-tabs-modified-marker-selected         (:background crust :foreground text))
  (centaur-tabs-close-selected                   (:inherit 'centaur-tabs-selected))

  (centaur-tabs-unselected                       (:background mantle :foreground overlay2))
  (centaur-tabs-unselected-modified              (:background mantle :foreground mauve))
  (centaur-tabs-modified-marker-unselected       (:background mantle :foreground overlay2))
  (centaur-tabs-close-unselected                 (:background mantle :foreground overlay2))

  (centaur-tabs-close-mouse-face                 (:background nil :foreground red))
  (centaur-tabs-default                          (:background mantle))
  (centaur-tabs-name-mouse-face                  (:foreground blue :bold t))

  (git-gutter:added                              (:foreground green))
  (git-gutter:deleted                            (:foreground red))
  (git-gutter:modified                           (:foreground blue))

  ;; tree sitter highlightning
  (tree-sitter-hl-face:function                  (:foreground blue))
  (tree-sitter-hl-face:function.call             (:foreground sapphire :italic t :underline t))
  (tree-sitter-hl-face:function.builtin          (:foreground sky))
  (tree-sitter-hl-face:function.special          (:foreground text :italic t :bold t))
  (tree-sitter-hl-face:function.macro            (:foreground sapphire))

  (tree-sitter-hl-face:method                    (:foreground blue :italic t))
  (tree-sitter-hl-face:method.call               (:foreground peach))

  (tree-sitter-hl-face:type                      (:foreground maroon :bold t))
  (tree-sitter-hl-face:type.parameter            (:foreground sapphire :italic t))
  (tree-sitter-hl-face:type.argument             (:foreground subtext0 :background peach))
  (tree-sitter-hl-face:type.builtin              (:foreground peach :italic t))
  (tree-sitter-hl-face:type.super                (:foreground green :bold t))
  (tree-sitter-hl-face:constructor               (:foreground teal :weight 'semi-bold))

  (tree-sitter-hl-face:variable                  (:foreground rosewater))
  (tree-sitter-hl-face:variable.parameter        (:foreground flamingo))
  (tree-sitter-hl-face:variable.builtin          (:foreground mauve :bold t))
  (tree-sitter-hl-face:variable.special          (:foreground mauve))
  (tree-sitter-hl-face:property                  (:foreground rosewater))
  (tree-sitter-hl-face:property.definition       (:foreground rosewater :italic t))

  (tree-sitter-hl-face:comment                   (:foreground surface2 :italic t))
  (tree-sitter-hl-face:doc                       (:foreground blue :italic t))
  (tree-sitter-hl-face:string                    (:foreground green :italic t))
  (tree-sitter-hl-face:string.special            (:foreground green :italic t))
  (tree-sitter-hl-face:escape                    (:foreground yellow :background surface1))
  (tree-sitter-hl-face:embedded                  (:foreground teal))

  (tree-sitter-hl-face:keyword                   (:foreground maroon :bold t))
  (tree-sitter-hl-face:operator                  (:foreground blue :bold t))
  (tree-sitter-hl-face:label                     (:inherit 'tree-sitter-hl-face:keyword :italic t))
  (tree-sitter-hl-face:constant                  (:foreground yellow))
  (tree-sitter-hl-face:constant.builtin          (:foreground yellow :weight 'semi-bold))
  (tree-sitter-hl-face:number                    (:foreground peach))

  (tree-sitter-hl-face:punctuation               (:foreground maroon))
  (tree-sitter-hl-face:punctuation.bracket       (:foreground subtext1))
  (tree-sitter-hl-face:punctuation.delimiter     (:foreground text :bold t))
  (tree-sitter-hl-face:punctuation.special       (:foreground yellow))

  (tree-sitter-hl-face:case-pattern              (:foreground peach))
  (tree-sitter-hl-face:keyword.compiler          (:foreground overlay2 :bold t :italic t))

  ;; custom for pinkus tree-sitter-swift
  (tree-sitter-hl-face:include                   (:foreground mauve :italic t))
  (tree-sitter-hl-face:parameter                 (:foreground sky))
  (tree-sitter-hl-face:repeat                    (:foreground blue :bold t))
  (tree-sitter-hl-face:boolean                   (:foreground yellow))
  (tree-sitter-hl-face:keyword.return            (:foreground maroon :bold t :italic t))
  (tree-sitter-hl-face:keyword.operator          (:foreground sapphire :bold t))
  (tree-sitter-hl-face:keyword.function          (:foreground maroon :bold t))
  (tree-sitter-hl-face:conditional               (:foreground lavender :bold t))
  
  (swift-mode:preprocessor-keyword-face (:foreground text :italic t))
  (swift-mode:property-access-face (:foreground subtext1))
  (swift-mode:builtin-property-face (:foreground teal))
  (swift-mode:builtin-enum-case-face (:foreground teal))
  (swift-mode:builtin-method-trailing-closure-face (:foreground teal))
  (swift-mode:builtin-function-trailing-closure-face (:foreground teal))
  
  ;; Page break lines
  (page-break-lines (:foreground surface0))
  ))

;;;###autoload
(and load-file-name
     (boundp 'custom-theme-load-path)
     (add-to-list 'custom-theme-load-path
		  (file-name-as-directory
		   (file-name-directory load-file-name))))

(provide-theme 'catppuccin-mocha)
;;; catppuccin-mocha-theme.el ends here
