{
  inputs = {
    # -----------------------
    # ci/cd

    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";

    # -----------------------
    # package repositories

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=d917136f550a8c36efb1724390c7245105f79023";

    # NUR
    nur-src.url = "github:nix-community/NUR";

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    vim-extra-plugins.url = "github:m15a/nixpkgs-vim-extra-plugins?ref=3e08bbd37dc9bec38d9a4d8597a90d80372b47af";

    # -----------------------
    # flake utilities

    flake-parts.url = "github:hercules-ci/flake-parts";

    # devshell for some nice menu + easy command adding capabilities
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # -----------------------
    # single applications/services

    spicetify.url = "github:the-argus/spicetify-nix";
    spicetify.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: once my prs are merged revert to main repo
    #eww-git.url = "github:elkowar/eww?ref=7623e7e692042f4da8525bb1e4ef140831fcdb6a";
    #eww-git.url = "github:PhilTaken/eww?ref=7837576ee0d2b5ba93b7c9bace0a66338897f5ef";
    eww-git.url = "github:ralismark/eww?ref=68471c9b23e55ad3c8b31a99473552e16594a44f";

    # better discord clone/fork
    webcord.url = "github:fufexan/webcord-flake";

    # best nix language server
    nil-ls.url = "github:oxalica/nil";

    # deploy remote setups
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly.url = "github:neovim/neovim?dir=contrib";

    hyprland = {
      url = "github:vaxerski/Hyprland";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    xdg-desktop-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";

    arm-rs = {
      url = "github:PhilTaken/arm.rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";

    parinfer-rust.url = "github:PhilTaken/parinfer-rust";

    # -----------------------
    # non-flake sources

    tmm-src = {
      url = "https://release.tinymediamanager.org/v4/dist/tmm_4.3.8.1_linux-amd64.tar.gz";
      flake = false;
    };

    down_on_spot-src = {
      url = "github:oSumAtrIX/DownOnSpot?ref=e0595feae8ee54c47fec82cf513e29f1abacfbfe";
      flake = false;
    };

    tmux-nvr-src = {
      url = "github:carlocab/tmux-nvr";
      flake = false;
    };

    #autoeq = {
      #url = "github:jaakkopasanen/AutoEq";
      #flake = false;
    #};

    fish-pisces-src = {
      url = "github:laughedelic/pisces";
      flake = false;
    };

    alacritty-catppuccin = {
      url = "github:catppuccin/alacritty";
      flake = false;
    };

    # nextcloud apps
    nc-calendar = {
      url = "https://github.com/nextcloud/calendar/archive/refs/tags/v3.3.2.tar.gz";
      flake = false;
    };

    nc-news = {
      url = "https://github.com/nextcloud/news/releases/download/20.0.0/news.tar.gz";
      flake = false;
    };

    nc-bookmarks = {
      url = "https://github.com/nextcloud/bookmarks/releases/download/v12.0.0/bookmarks-12.0.0.tar.gz";
      flake = false;
    };

    # extra vim plugins
    vim-janet-src = {
      url = "github:bakpakin/janet.vim";
      flake = false;
    };

    vim-terraform-src = {
      url = "github:hashivim/vim-terraform";
      flake = false;
    };

    vim-yuck-src = {
      url = "github:elkowar/yuck.vim";
      flake = false;
    };

    vim-async-src = {
      url = "github:kevinhwang91/promise-async";
      flake = false;
    };

    # colorscheme
    catppuccin-base16 = {
      url = "github:catppuccin/base16";
      flake = false;
    };
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      imports = [
        ./modules/flake/configurations.nix
        ./modules/flake/modules.nix
        ./modules/flake/deploy.nix
        ./modules/flake/shells.nix
        inputs.hercules-ci-effects.flakeModule
      ];

      #hercules-ci.flake-update = {
        #enable = true;
        #when = {
          #hour = [ 23 ];
          #dayOfWeek = ["Sun" "Wed"];
        #};
      #};
    };
}
