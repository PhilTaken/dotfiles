{ pkgs
, ...
}:
{
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
    oxygen_gtk
    plasma-browser-integration
    rofi
    rofi-pass
    xclip
  ];
}
