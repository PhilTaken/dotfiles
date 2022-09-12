{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.mail;
in
{

  options.phil.mail = {
    enable = mkOption {
      description = "Enable the mail module";
      type = types.bool;
      default = true;
    };
  };


  config = mkIf cfg.enable {
    programs = {
      #lieer.enable = true;
      #notmuch.enable = true;
      #afew.enable = true;
      #neomutt = {
      #enable = true;
      #};
    };

    #xdg.configFile."newsboat/config".source = ./config/newsboat/config;

    home.packages = with pkgs; [
      thunderbird
      hydroxide
    ];

    # protonmail bridge
    systemd.user.services.hydroxide = {
      Unit = {
        Description = "Unit for the hydroxide protonmail bridge";
        After = "graphical-session-pre.target";
        PartOf = "graphical-session.target";
      };

      Service = {
        ExecStart = "${pkgs.hydroxide}/bin/hydroxide serve";
        Restart = "on-abort";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

  };
}
