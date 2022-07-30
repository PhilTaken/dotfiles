{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.wms.bars.eww;
  package = if cfg.enableWayland then pkgs.eww-git-wayland else pkgs.eww-git;
in
{
  options.phil.wms.bars.eww = {
    enable = mkOption {
      description = "enable eww module";
      type = types.bool;
      default = false;
    };

    enableWayland = mkOption {
      description = "build wayland package";
      type = types.bool;
      default = true;
    };

    autostart = mkOption {
      description = "autotstart the bar";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    phil.wms.bars.barcommand = mkIf (cfg.autostart) "${package}/bin/eww open bar";

    home.packages = with pkgs; [
      kde-gtk-config
      package
    ];

    programs.eww = {
      enable = true;
      inherit package;
      configDir = (pkgs.stdenv.mkDerivation rec {
        pname = "eww-configfolder";
        version = "0.1";

        src = ./config;

        # TODO: replace commands with actual paths to binaries
        buildPhase = ''
        '';

        installPhase = ''
          mkdir -p $out
          cp -r $src/* $out
        '';
      });
    };

    #systemd.user.services.eww-bar = {
      #Unit = {
        #Description = "Unit for the eww daemon";
        #After = "graphical-session-pre.target";
        #PartOf = "graphical-session.target";
      #};

      #Service = {
        #ExecStart = ''
          #${package}/bin/eww --no-daemonize daemon
        #'';
        #Restart = "on-abort";
      #};

      #Install = {
        #WantedBy = [ "graphical-session.target" ];
      #};
    #};
  };
}
