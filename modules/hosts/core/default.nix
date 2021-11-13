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
  };

  config = mkIf (cfg.enable)
    {
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

      # links /libexec from derivations to /run/current-system/sw
      environment.pathsToLink = [ "/libexec" ];

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
      #programs.steam.enable = true;

      services = {
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
        htop
      ];

      system.stateVersion = "21.05";
    };
}
