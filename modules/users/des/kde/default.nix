{ pkgs
, config
, lib
, ...
}:

let
  cfg = config.phil.des.kde;
  inherit (lib) mkEnableOption mkOption types mkIf;
in
{
  options.phil.des.kde = {
    enable = mkEnableOption "kde";

    default_font = mkOption {
      description = "default font";
      type = types.str;
      default = "Iosevka Comfy";
    };
  };

  config = mkIf cfg.enable {
    services.kdeconnect.enable = true;

    programs = {
      alacritty = {
        enable = true;
        settings = {
          font.normal.family = cfg.default_font;
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
