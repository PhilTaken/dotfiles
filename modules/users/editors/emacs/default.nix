{ pkgs
, config
, lib
, inputs
, ...
}:
with lib;

let
  cfg = config.phil.editors.emacs;
in
{
  imports = [
    inputs.nix-doom-emacs.hmModule
  ];

  options.phil.editors.emacs = {
    enable = mkOption {
      description = "enable emacs module";
      type = types.bool;
      default = true;
    };

    langs = {
      python = mkOption {
        description = "enable the python integration";
        type = types.bool;
        default = true;
      };

      ts = mkOption {
        description = "enable the js/ts integration";
        type = types.bool;
        default = true;
      };

      cpp = mkOption {
        description = "enable the cpp integration";
        type = types.bool;
        default = true;
      };

      rust = mkOption {
        description = "enable the rust integration";
        type = types.bool;
        default = true;
      };

      haskell = mkOption {
        description = "enable the haskell integration";
        type = types.bool;
        default = true;
      };

      extra = mkOption {
        description = "enable extra integrations";
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {
    programs.doom-emacs = let
      extraBins = with pkgs; [
        gcc11
        gcc-unwrapped

        tree-sitter

        git # version control
        ripgrep # telescope file finding
        fd # faster find
        gcc # for treesitter

        bottom # custom floaterm
        universal-ctags # ctags for anything
        inetutils # remote editing

        sumneko-lua-language-server # lua
        nil # nix
      ]
      ++ (optionals cfg.langs.python (with pkgs.python39Packages; [ python-lsp-server hy ]))
      ++ (optionals cfg.langs.ts [ pkgs.nodePackages.typescript-language-server ])
      ++ (optionals cfg.langs.cpp [ pkgs.ccls ])
      ++ (optionals cfg.langs.rust [ pkgs.rust-analyzer ])
      ++ (optionals cfg.langs.haskell [ pkgs.haskell-language-server ])
      ++ (optionals cfg.langs.extra (with pkgs; [
        fortls
        texlab
        #erlang-ls # erlang
        #elixir_ls # elixir
        #clojure-lsp # clojure
      ]));
    in {
      enable = true;
      doomPrivateDir = ./doom.d;
      extraConfig = ''
        (setq exec-path (append exec-path '( ${
          concatMapStringsSep " " (x: ''"${x}/bin"'') extraBins
        } )))
        (setenv "PATH" (concat (getenv "PATH") ":${
          concatMapStringsSep ":" (x: "${x}/bin") extraBins
        }"))
      '';
    };

    services.emacs.enable = true;
  };
}
