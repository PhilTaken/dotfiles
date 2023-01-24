{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkOption mkIf types;
  cfg = config.phil.sound;
in
{
  options.phil.sound = {
    enable = mkOption {
      description = "enable the sound module";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.spotify-username = { };
    sops.secrets.spotify-password = {
      group = "audio";
      mode = "0440";
    };

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

  };
}
