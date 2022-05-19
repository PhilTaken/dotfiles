{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.editors.spacemacs;
in
{
  options.phil.editors.spacemacs = {
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
        ac-ispell
        ace-jump-helm-line
        ace-link
        ace-window
        aggressive-indent
        alert
        all-the-icons
        anaconda-mode
        annalist
        anzu
        async
        attrap
        auto-compile
        auto-complete
        auto-highlight-symbol
        auto-yasnippet
        avy
        ayu-theme
        bind-key
        bind-map
        blacken
        browse-at-remote
        bui
        cargo
        centered-cursor-mode
        cfrs
        clang-format
        clean-aindent-mode
        closql
        cmm-mode
        column-enforce-mode
        company
        company-anaconda
        company-cabal
        company-nixos-options
        concurrent
        ctable
        cython-mode
        dante
        dap-mode
        dash
        deferred
        define-word
        devdocs
        diminish
        dired-quick-sort
        direnv
        dotenv-mode
        drag-stuff
        dumb-jump
        editorconfig
        elisp-def
        elisp-slime-nav
        emacsql
        emacsql-sqlite
        emr
        epc
        epl
        esh-help
        eshell-prompt-extras
        eshell-z
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
        evil-nerd-commenter
        evil-numbers
        evil-org
        evil-surround
        evil-terminal-cursor-changer
        evil-textobj-line
        evil-tutor
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
        flycheck-haskell
        flycheck-package
        flycheck-pos-tip
        flycheck-rust
        font-lock-plus
        forge
        fringe-helper
        fuzzy
        gh-md
        ghub
        git-commit
        git-gutter
        git-gutter-fringe
        git-link
        git-messenger
        git-modes
        git-timemachine
        gitignore-templates
        gntp
        gnuplot
        golden-ratio
        google-translate
        goto-chg
        haskell-mode
        haskell-snippets
        helm
        helm-ag
        helm-c-yasnippet
        helm-company
        helm-core
        helm-descbinds
        helm-flx
        helm-git-grep
        helm-hoogle
        helm-ls-git
        helm-lsp
        helm-make
        helm-mode-manager
        helm-nixos-options
        helm-org
        helm-org-rifle
        helm-projectile
        helm-purpose
        helm-pydoc
        helm-swoop
        helm-themes
        helm-xref
        highlight-indentation
        highlight-numbers
        highlight-parentheses
        hindent
        hl-todo
        hlint-refactor
        ht
        htmlize
        hungry-delete
        hydra
        iedit
        imenu-list
        importmagic
        indent-guide
        lcr
        link-hint
        list-utils
        live-py-mode
        log4e
        lorem-ipsum
        lsp-haskell
        lsp-mode
        lsp-origami
        lsp-pyright
        lsp-python-ms
        lsp-treemacs
        lsp-ui
        lv
        macrostep
        magit
        magit-section
        markdown-mode
        markdown-toc
        memoize
        mmm-mode
        multi-line
        multi-term
        mwim
        nameless
        nix-mode
        nixos-options
        open-junk-file
        org-category-capture
        org-cliplink
        org-contrib
        org-contrib
        org-download
        org-mime
        org-pomodoro
        org-present
        org-projectile
        org-rich-yank
        org-superstar
        orgit
        orgit-forge
        origami
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
        pip-requirements
        pipenv
        pippel
        pkg-info
        poetry
        popup
        popwin
        pos-tip
        posframe
        powerline
        projectile
        py-isort
        pydoc
        pyenv-mode
        pytest
        pythonic
        pyvenv
        queue
        queue
        quickrun
        racer
        rainbow-delimiters
        request
        restart-emacs
        ron-mode
        rust-mode
        s
        shell-pop
        shut-up
        smartparens
        smeargle
        spaceline
        spaceline-all-the-icons
        sphinx-doc
        spinner
        spinner
        string-edit
        string-inflection
        symbol-overlay
        symon
        terminal-here
        toc-org
        toml-mode
        transient
        treemacs
        treemacs-evil
        treemacs-icons-dired
        treemacs-magit
        treemacs-persp
        treemacs-projectile
        treepy
        undo-tree
        undo-tree
        unfill
        use-package
        uuidgen
        vi-tilde-fringe
        visual-fill-column
        volatile-highlights
        vterm
        which-key
        window-purpose
        winum
        with-editor
        writeroom-mode
        ws-butler
        xterm-color
        yaml
        yaml-mode
        yapfify
        yasnippet
        yasnippet-snippets
      ];
    };
    # nose

    home.file.".emacs.d" = {
      source = cfg.spacemacs-path;
      recursive = true;
    };

    home.file.".emacs.d/elpa/28.1/develop/" = {
      source = ./extraModules;
      recursive = true;
    };

    home.file.".spacemacs".source = ./config.el;
    home.file.".spacemacs.env".text = let
      extraPackages = with pkgs; [
          rust-analyzer
          rnix-lsp
          haskell-language-server # haskell
          (python3.withPackages (pypacks: with pypacks; [
            python-lsp-server
          ]))
      ];
      extraPath = lib.concatStringsSep ":" (builtins.map (pkg: "${pkg}/bin") extraPackages);
    in ''
      USER=nixos
      HOME=/home/nixos
      PWD=/home/nixos
      SHELL=/run/current-system/sw/bin/zsh
      PATH=/run/wrappers/bin:/home/nixos/.nix-profile/bin:/etc/profiles/per-user/nixos/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:${extraPath}
    '';
  };
}

