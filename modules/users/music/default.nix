{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.music;
in
{
  options.phil.music = {
    enable = mkOption {
      description = "Enable the music module";
      type = types.bool;
      default = false;
    };

    enableMpris = mkEnableOption "mpris";
  };

  config = (mkIf cfg.enable) {

    systemd.user.services.mpris-proxy = mkIf (cfg.enableMpris) {
      Unit.Description = "Mpris proxy";
      Unit.After = [ "network.target" "sound.target" ];
      Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
      Install.WantedBy = [ "default.target" ];
    };

    #programs.spicetify = {
      #enable = true;
      #theme = "Onepunch";
      ##colorScheme = "Nord-Dark";
      ##enabledCustomApps = ["reddit"];
      ##enabledExtensions = ["newRelease.js"];
    #};

    home.packages = with pkgs; [
      #spotify-unwrapped

      spotify
      ffmpeg
      playerctl
      pamixer
      pavucontrol
      mpv
    ];
  };
}
