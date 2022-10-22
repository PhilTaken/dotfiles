{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.wms.bars.eww;
  package = if cfg.enableWayland then pkgs.eww-wayland else pkgs.eww;
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

    reload_cmd = mkOption {
      description = "command to reload the wm";
      type = types.str;
      default = "hyprctl reload && notify-send \"ok\"";
    };

    quit_cmd = mkOption {
      description = "command to quit the wm";
      type = types.str;
      default = "hyprctl kill";
    };

    lock_cmd = mkOption {
      description = "command to lock the wm";
      type = types.str;
      default = "${pkgs.swaylock}/bin/swaylock -c 000000";
    };

    main_monitor = mkOption {
      description = "main monitor for the sidebar + calendar popup";
      type = types.int;
      default = 0;
    };
  };

  config = mkIf cfg.enable {
    phil.wms.bars.barcommand = mkIf cfg.autostart "${package}/bin/eww open bar";

    home.packages = with pkgs; [
      kde-gtk-config
      package
    ];

    programs.eww = {
      enable = true;
      inherit package;
      configDir = pkgs.stdenv.mkDerivation rec {
        pname = "eww-configfolder";
        version = "0.1";
        phases = [ "patchPhase" ];

        src = ./config;

        # TODO: replace commands with actual paths to binaries
        patchPhase = ''
          mkdir -p $out
          cp -r $src/* $out

          substituteInPlace $out/eww.yuck \
            --replace '@amixer@' '${pkgs.alsa-utils}/bin/amixer' \
            --replace '@eww@' '${package}/bin/eww' \
            --replace '@brightnessctl@' '${pkgs.brightnessctl}/bin/brightnessctl' \
            --replace '@reload_wm@' '${cfg.reload_cmd}' \
            --replace '@quit_wm@' '${cfg.quit_cmd}' \
            --replace '@lock_wm@' '${cfg.lock_cmd}' \
            --replace '@main_monitor@' '${builtins.toString cfg.main_monitor}'

          substituteInPlace $out/scripts/workspace \
            --replace '@socat@' '${pkgs.socat}/bin/socat' \
            --replace '@hyprctl@' '${pkgs.hyprland}/bin/hyprctl' \
            --replace '@jq@' '${pkgs.jq}/bin/jq'
        '';
      };
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
