{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.sound;
in {
  options.phil.sound = {
    enable = mkOption {
      description = "enable the sound module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    # Enable sound.
    sound.enable = true;
    sound.mediaKeys.enable = true;

    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-gtk
        ];
        gtkUsePortal = true;
      };
    };
  };
}

