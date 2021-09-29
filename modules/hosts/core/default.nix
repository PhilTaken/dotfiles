{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.core;
in {
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

    hardware-config = mkOption {
      description = "Hardware config to import";
      type = types.nullOr types.path;
      default = null;
    };

    hostname = mkOption {
      description = "System hostname";
      type = types.str;
      default = "nixos";
    };

    timezone = mkOption {
      description = "System timezone";
      type = types.str;
      default = "Europe/Berlin";
    };

    enable_ssh = mkOption {
      description = "Enable the ssh daemon";
      type = types.bool;
      default = false;
    };

    extraconfig = mkOption {
      description = "extra config";
      type = types.attrsOf types.anything;
      default = {};
    };
  };

  config = mkIf (cfg.enable) {
    imports = if (cfg.hardware-config != null) then [ cfg.hardware-config ] else [];

    nix = {
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      autoOptimiseStore = true;
      trustedUsers = [ "root" "@wheel" ];

      # TODO add my own registry
      registry = { };
    };
    hardware.enableRedistributableFirmware = true;
    environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw


    # TODO make this configurable (efi/grub for legacy)
    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostname = cfg.hostname;
    time.timeZone = cfg.timezone;

    virtualisation.docker.enable = cfg.docker;

    services = {
      sshd.enable = cfg.enable_ssh;
      tailscale.enable = true;
    };

    programs = {
      mtr.enable = true;
      command-not-found.enable = false;
      zsh = {
        enable = true;
        interactiveShellInit = ''
          source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
        '';
      };
    };

    environment.systemPackages = with pkgs; [
      vim
      git
      git-crypt
      cryptsetup
      hwinfo
      nix-index
    ];

    # ----------------

    system.stateVersion = "21.05";
  } // cfg.extraconfig;
}
