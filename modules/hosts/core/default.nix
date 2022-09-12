{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.core;
in
{
  options.phil.core = {
    enable = mkOption {
      description = "Enable core module";
      type = types.bool;
      default = true;
    };

    docker = mkOption {
      description = "Enable docker";
      type = types.bool;
      default = false;
    };

    hostName = mkOption {
      description = "System hostname";
      type = types.str;
      default = "nixos";
    };

    timeZone = mkOption {
      description = "System timezone";
      type = types.str;
      default = "Europe/Berlin";
    };

    enableBluetooth = mkEnableOption "bluetooth";
  };

  config = mkIf cfg.enable {
    nix = {
      package = pkgs.nixFlakes;
      # Free up to 1GiB whenever there is less than 100MiB left.
      extraOptions = ''
        experimental-features = nix-command flakes
        min-free = ${toString (100 * 1024 * 1024)}
        max-free = ${toString (1024 * 1024 * 1024)}
        tarball-ttl = ${toString (7 * 24 * 60 * 60)}
      '';

      # TODO add my own registry
      registry = {
        flake-templates = {
          from = {
            id = "custom";
            type = "indirect";
          };
          to = {
            owner = "PhilTaken";
            repo = "flake-templates";
            type = "github";
          };
        };
      };

      settings = {
        trusted-users = [ "root" "@wheel" ];
        substituters = [
          "https://philtaken.cachix.org"
          "https://arm-rs.cachix.org"
          "https://cache.iog.io"
          "https://hyprland.cachix.org"
          "s3://serokell-private-nix-cache?endpoint=s3.us-west-000.backblazeb2.com&profile=serokell-private-nix-cache"
          "s3://serokell-private-cache?endpoint=s3.eu-central-1.wasabisys.com&profile=serokell-private-cache"
          "https://nixpkgs-wayland.cachix.org"
          "https://cache.nixos.org"
        ];
        auto-optimise-store = true;
        trusted-public-keys = [
          "philtaken.cachix.org-1:EJiUqY2C0igyW8Sxzcna4JjAhhR4n13ZLvycFcE7jvk="
          "arm-rs.cachix.org-1:bgjtu4We0K2fhd7n2E5Dv136XeLk2yXZcrTrCguWsls="
          "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "serokell-1:aIojg2Vxgv7MkzPJoftOO/I8HKX622sT+c0fjnZBLj0="
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
      # set up automatic garbage collection
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

    hardware.enableRedistributableFirmware = true;

    # link to cachix token env file
    sops.secrets.cachix-token = { };

    # links /libexec from derivations to /run/current-system/sw
    environment.pathsToLink = [ "/libexec" ];

    networking.hostName = cfg.hostName;
    time.timeZone = cfg.timeZone;

    # TODO move these somewhere else
    virtualisation.docker.enable = cfg.docker;

    # tailscale - wireguard mesh vpn
    services.tailscale.enable = true;
    networking.firewall.checkReversePath = "loose";

    # bluetooth
    hardware.bluetooth = mkIf cfg.enableBluetooth {
      enable = cfg.enableBluetooth;
      powerOnBoot = true;
    };
    services.blueman.enable = cfg.enableBluetooth;

    # core packages + shell setup
    programs = {
      mtr.enable = true;
      zsh.enable = true;
      command-not-found.enable = false;
    };

    environment.systemPackages = with pkgs; [
      vim
      git
      git-crypt
      cryptsetup
      hwinfo
      htop
      #magic-wormhole
    ];
  };
}
