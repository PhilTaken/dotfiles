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
      default = true;
    };

    enableMpris = mkEnableOption "mpris";
  };

  config = (mkIf cfg.enable) {

    systemd.user.services.mpris-proxy = mkIf cfg.enableMpris {
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

    programs.spicetify = {
      enable = true;
      theme = "catppuccin-mocha";
      # OR
      # theme = spicetify-nix.pkgSets.${pkgs.system}.themes.catppuccin-mocha;
      colorScheme = "flamingo";

      enabledExtensions = [
        "fullAppDisplay.js"
        "shuffle+.js"
        "hidePodcasts.js"
      ];
    };

    services.easyeffects.enable = true;

    home.packages = with pkgs; [
      #spotify-unwrapped
      #spotify

      ffmpeg
      playerctl
      pamixer
      pavucontrol
      mpv
    ];
  };
}
