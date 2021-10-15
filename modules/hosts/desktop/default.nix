{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.desktop;
in
{
  options.phil.desktop = {
    enable = mkOption {
      description = "enable desktop module";
      type = types.bool;
      default = false;
    };

    # more options
  };

  config = mkIf (cfg.enable) {
    programs.steam.enable = true;

    environment.systemPackages =
      let
        libbluray = pkgs.libbluray.override {
          withAACS = true;
          withBDplus = true;
        };
        vlc = pkgs.vlc.override { inherit libbluray; };
      in
      with pkgs; [
        vlc
        audacity
        chromium
        citra
        multimc
        obs-studio
        citra
        openttd
        makemkv
      ];

    services.jellyfin.enable = true;
    services.jellyfin.openFirewall = true;

  };
}

