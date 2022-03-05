{ pkgs
, config
, lib
, ...
}:
with lib;

let cfg = config.phil.kde;
in
{
  options.phil.kde = {
    enable = mkOption {
      description = "Enable the kde window manager (plasma 5)";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    services.kdeconnect.enable = true;

    programs = {
      alacritty = {
        enable = true;
        settings = {
          font.normal.family = "iosevka";
          font.size = 12.0;
        };
      };
    };

    systemd.user.services.flameshot = {
      Unit = {
        Description = "Unit for the flameshot daemon";
        After = "graphical-session-pre.target";
        PartOf = "graphical-session.target";
      };

      Service = {
        ExecStart = "${pkgs.flameshot}/bin/flameshot";
        Restart = "on-abort";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };


    home.packages = with pkgs; [
      flameshot
      latte-dock
      libnotify
      plasma-browser-integration
      rofi
      #rofi-pass
      xclip

      libsForQt5.bismuth
    ];
  };
}
