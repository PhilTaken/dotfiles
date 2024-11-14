{
  inputs = {
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";

    # -----------------------
    # package repositories

    # nixpkgs.url = "github:nixos/nixpkgs/cd11caeb123796cbd017af8514e7c0657a767527";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nur-src.url = "github:nix-community/NUR";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixneovimplugins.url = "github:jooooscha/nixpkgs-vim-extra-plugins";

    # -----------------------
    # macos inputs (work laptop)
    # locked to specific version due to https://github.com/LnL7/nix-darwin/issues/1082
    #darwin.url = "github:lnl7/nix-darwin/f4f18f3d7229845e1c9d517457b7a0b90a38b728";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # -----------------------
    # flake utilities
    flake-parts.url = "github:hercules-ci/flake-parts";

    # devshell for some nice menu + easy command adding capabilities
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";

    # -----------------------
    # nixos modules

    stylix.url = "github:danth/stylix";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # local user package managment
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # for secret managment
    sops-nix-src = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # -----------------------
    # single applications/services

    # deploy remote setups
    deploy-rs = {
      url = "github:philtaken/deploy-rs/phil/optimize-compile-times";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify.url = "github:Gerg-L/spicetify-nix";
    spicetify.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: once my prs are merged revert to main repo
    #eww-git.url = "github:elkowar/eww?ref=7623e7e692042f4da8525bb1e4ef140831fcdb6a";
    #eww-git.url = "github:PhilTaken/eww?ref=7837576ee0d2b5ba93b7c9bace0a66338897f5ef";
    eww-git.url = "github:ralismark/eww?ref=68471c9b23e55ad3c8b31a99473552e16594a44f";

    # better discord clone/fork
    webcord.url = "github:fufexan/webcord-flake";

    # best nix language server
    nil-ls.url = "github:oxalica/nil";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    neorg-overlay.inputs.nixpkgs.follows = "nixpkgs";

    #hyprland = {
    #url = "github:vaxerski/Hyprland";
    #inputs.nixpkgs.follows = "nixpkgs";
    #};

    #xdg-desktop-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    parinfer-rust.url = "github:PhilTaken/parinfer-rust";

    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # time tracker
    #ttrack.url = "git+https://gitea.pherzog.xyz/phil/ttrack";
    dimsum.url = "git+https://gitea.pherzog.xyz/mini-x/dimsum";
    fc-utils.url = "git+https://gitea.pherzog.xyz/phil/fc-utils";

    gleamdication.url = "git+https://gitea.pherzog.xyz/phil/gleamdication";
    gleamdication.inputs.nixpkgs.follows = "nixpkgs";
    gleamdication.inputs.flake-parts.follows = "flake-parts";

    # -----------------------
    # non-flake sources
    # TODO: manage without flakes

    #tmm-src = {
    #url = "https://release.tinymediamanager.org/v5/dist/tinyMediaManager-5.0.4-linux-amd64.tar.xz";
    #flake = false;
    #};
  };

  outputs = {flake-parts, ...} @ inputs: let
    custom_pkgs_overlay = import ./custom_pkgs;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      flake.overlays = {
        inherit custom_pkgs_overlay;
        default = custom_pkgs_overlay;
      };

      imports = [
        ./modules/flake/configurations.nix
        ./modules/flake/modules.nix
        ./modules/flake/deploy.nix
        ./modules/flake/shells.nix
        inputs.treefmt-nix.flakeModule
        inputs.pre-commit-hooks-nix.flakeModule
        #      inputs.disko.nixosModules.disko
      ];

      perSystem = {
        config,
        pkgs,
        ...
      }: {
        pre-commit = {
          settings.hooks = {
            alejandra.enable = true;
            #treefmt.enable = true;
          };
        };

        treefmt = {
          projectRootFile = "flake.nix";
          programs.alejandra.enable = true;
          programs.stylua.enable = true;
          programs.deadnix.enable = true;
        };

        formatter = config.treefmt.build.wrapper;

        # filter packages by compatibility
        packages = let
          inherit (pkgs) lib system;
          l = builtins // lib;
        in
          pkgs.lib.filterAttrs
          (_: package:
            if l.hasAttrByPath ["meta" "platforms"] package
            then l.elem system package.meta.platforms
            else (lib.hasInfix "linux" pkgs.system))
          (custom_pkgs_overlay pkgs pkgs);
      };
    };
}
