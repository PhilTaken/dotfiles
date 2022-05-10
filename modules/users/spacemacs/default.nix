{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.spacemacs;
in
{
  options.phil.spacemacs = {
    enable = mkOption {
      description = "enable spacemacs module";
      type = types.bool;
      default = false;
    };

    spacemacs-path = mkOption {
      description = "link to spacemacs config";
      type = types.path;
    };
  };

  config = mkIf (cfg.enable) {
    programs.emacs = {
      enable = true;
      extraPackages = epkgs: with epkgs; [
        ace-jump-helm-line
        ace-link
        ace-window
        aggressive-indent
        all-the-icons
        annalist
        anzu
        async
        auto-compile
        auto-highlight-symbol
        avy
        bind-key
        bind-map
        centered-cursor-mode
        cfrs
        clang-format
        clean-aindent-mode
        column-enforce-mode
        dash
        define-word
        devdocs
        diminish
        dired-quick-sort
        dotenv-mode
        drag-stuff
        dumb-jump
        editorconfig
        elisp-def
        elisp-slime-nav
        emr
        epl
        eval-sexp-fu
        evil
        evil-anzu
        evil-args
        evil-cleverparens
        evil-collection
        evil-easymotion
        evil-ediff
        evil-escape
        evil-exchange
        evil-goggles
        evil-iedit-state
        evil-indent-plus
        evil-lion
        evil-lisp-state
        evil-matchit
        evil-mc
        evil-nerd-commenter
        evil-numbers
        evil-surround
        evil-terminal-cursor-changer
        evil-textobj-line
        evil-tutor
        #evil-unimpaired
        evil-visual-mark-mode
        evil-visualstar
        expand-region
        eyebrowse
        f
        fancy-battery
        flx
        flx-ido
        flycheck
        flycheck-elsa
        flycheck-package
        font-lock-plus
        gh-md
        golden-ratio
        google-translate
        goto-chg
        helm
        helm-ag
        helm-core
        helm-descbinds
        helm-flx
        helm-make
        helm-mode-manager
        helm-org
        helm-projectile
        helm-purpose
        helm-swoop
        helm-themes
        helm-xref
        highlight-indentation
        highlight-numbers
        highlight-parentheses
        hl-todo
        ht
        hungry-delete
        hydra
        iedit
        imenu-list
        indent-guide
        link-hint
        list-utils
        lorem-ipsum
        lv
        macrostep
        markdown-mode
        markdown-toc
        memoize
        mmm-mode
        multi-line
        nameless
        open-junk-file
        org-superstar
        overseer
        package-lint
        packed
        paradox
        paredit
        parent-mode
        password-generator
        pcre2el
        persp-mode
        pfuture
        pkg-info
        popup
        popwin
        posframe
        powerline
        projectile
        queue
        queue
        quickrun
        rainbow-delimiters
        request
        restart-emacs
        s
        shut-up
        smartparens
        spaceline
        spaceline-all-the-icons
        spinner
        spinner
        string-edit
        string-inflection
        symbol-overlay
        symon
        toc-org
        treemacs
        treemacs-evil
        treemacs-icons-dired
        treemacs-persp
        treemacs-projectile
        undo-tree
        undo-tree
        use-package
        uuidgen
        visual-fill-column
        vi-tilde-fringe
        volatile-highlights
        which-key
        window-purpose
        winum
        writeroom-mode
        ws-butler
        yaml-mode
      ];
    };

    home.file.".emacs.d" = {
      source = cfg.spacemacs-path;
      recursive = true;
    };

    home.file.".emacs.d/elpa/28.1/develop/" = {
      source = ./extraModules;
      recursive = true;
    };

    # hide-comnt
    # info+
    # inspector
    # font-lock+

    home.file.".spacemacs".source = ./config.el;
  };
}

