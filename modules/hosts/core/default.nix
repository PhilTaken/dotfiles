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

    bootLoader = mkOption {
      description = "which bootloader to install";
      type = types.nullOr (types.enum [ "grub" "efi" ]);
      default = "efi";
    };

    grubDevice = mkOption {
      description = "which device to install grub on (if enabled via bootLoader)";
      type = types.nullOr types.str;
      default = null;
      example = "/dev/sda";
    };

    enableBluetooth = mkEnableOption "bluetooth";
  };

  config = mkIf (cfg.enable) {
    nix = {
      package = pkgs.nixFlakes;
      # Free up to 1GiB whenever there is less than 100MiB left.
      extraOptions = ''
        experimental-features = nix-command flakes
        min-free = ${toString (100 * 1024 * 1024)}
        max-free = ${toString (1024 * 1024 * 1024)}
      '';

      # TODO add my own registry
      registry = { };

      settings = {
        trusted-users = [ "root" "@wheel" ];
        substituters = [
          "https://philtaken.cachix.org"
          "https://cache.iog.io"
        ];
        auto-optimise-store = true;
        trusted-public-keys = [
          "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
          "philtaken.cachix.org-1:EJiUqY2C0igyW8Sxzcna4JjAhhR4n13ZLvycFcE7jvk="
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

    # maybe move this to each machine?
    boot = mkIf (cfg.bootLoader != null) {
      loader =
        if (cfg.bootLoader == "efi") then {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        } else {
          grub.enable = true;
          grub.version = 2;
          grub.device = if (cfg.grubDevice != null) then cfg.grubDevice else throw "you need to set a grub device";
        };
    };

    networking.hostName = cfg.hostName;
    time.timeZone = cfg.timeZone;

    # TODO move these somewhere else
    virtualisation.docker.enable = cfg.docker;

    # tailscale - wireguard mesh vpn
    services.tailscale.enable = true;
    networking.firewall.checkReversePath = "loose";

    # bluetooth
    hardware.bluetooth = mkIf (cfg.enableBluetooth) {
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
      magic-wormhole
    ];

    system.stateVersion = "21.05";
  };
}
