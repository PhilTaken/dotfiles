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
  imports = [
    ./gmedia-extension.nix
  ];

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
    hardware.pulseaudio = {
      enable = false;
      extraModules = builtins.attrValues {
        inherit (pkgs) pulseaudio-dlna;
      };
    };

    services.gmediarender = {
      enable = false;
      uuid = "95a939fc-6330-434d-977d-97c4c46118e8";
      friendlyName = "render on ${config.networking.hostName}";
      #audioSink = "alsasink";
      #audioDevice = "default";
    };

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      lowLatency.enable = true;
    };
  };
}
