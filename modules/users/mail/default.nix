{
  config,
  lib,
  ...
}: let
  cfg = config.phil.mail;
  inherit (lib) mkEnableOption mkIf;
in {
  options.phil.mail = {
    enable = mkEnableOption "mail";
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

    home.packages = builtins.attrValues {
      # inherit (pkgs)
      #   thunderbird
      #   hydroxide;
    };

    # protonmail bridge
    #systemd.user.services.hydroxide = {
    #Unit = {
    #Description = "Unit for the hydroxide protonmail bridge";
    #After = "graphical-session-pre.target";
    #PartOf = "graphical-session.target";
    #};

    #Service = {
    #ExecStart = "${pkgs.hydroxide}/bin/hydroxide serve";
    #Restart = "on-abort";
    #};

    #Install = {
    #WantedBy = [ "graphical-session.target" ];
    #};
    #};
  };
}
