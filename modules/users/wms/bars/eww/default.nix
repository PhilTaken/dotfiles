{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.wms.bars.eww;
  ewwConfig = pkgs.stdenv.mkDerivation rec {
    pname = "eww-configfolder";
    version = "0.1";

    src = ./config;

    #buildInputs = with qt5; [ full ];
    #nativeBuildInputs = [ autoPatchelfHook ];

    buildPhase = ''
    '';

    installPhase = ''
      mkdir -p $out
      cp -r $src/* $out
    '';
  };
in {
  options.phil.wms.bars.eww = {
    enable = mkOption {
      description = "enable eww module";
      type = types.bool;
      default = false;
    };

    # more options
  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      kde-gtk-config
    ];

    programs.eww = {
      enable = true;
      configDir = ewwConfig;
    };

    # systemd.user.services.eww-bar = {
    #   Unit = {
    #     Description = "Unit for the eww daemon";
    #     After = "graphical-session-pre.target";
    #     PartOf = "graphical-session.target";
    #   };

    #   Service = {
    #     ExecStart = ''
    #       ${inputs.config.programs.eww.package}/bin/eww daemon --debug
    #     '';
    #     Restart = "on-abort";
    #   };

    #   Install = {
    #     WantedBy = [ "graphical-session.target" ];
    #   };
    # };
  };
}
