{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkOption mkIf types;
  cfg = config.phil.wms.bars.eww;
  package = if cfg.enableWayland then pkgs.eww-wayland else pkgs.eww;

  pylayerctl = pkgs.stdenv.mkDerivation rec {
    name = "pylayerctl";

    nativeBuildInputs = [
      pkgs.wrapGAppsHook
      pkgs.gobject-introspection
      pkgs.playerctl
    ];

    buildInputs = [
      pkgs.gobject-introspection
      pkgs.playerctl
    ];

    src = pkgs.writers.writePython3 "playerctl" {
      libraries = [
        pkgs.python3Packages.pygobject3
        pkgs.python3Packages.requests
        (pkgs.python3Packages.buildPythonPackage rec {
          pname = "material-color-utilities-python";
          version = "0.1.5";

          propagatedBuildInputs = with pkgs.python3Packages; [ regex pillow ];

          src = pkgs.fetchPypi {
            inherit pname version;
            sha256 = "sha256-PG8C585wWViFRHve83z3b9NijHyV+iGY2BdMJpyVH64=";
          };

          doCheck = false;
        })
      ];
      flakeIgnore = [
        "E116"
        "E222"
        "E226"
        "E231"
        "E261"
        "E402"
        "E501"
        "F401"
        "F403"
        "F405"
        "F841"
        "W503"
      ];
    } (builtins.readFile ./playerctl.py);
    dontUnpack = true;

    buildPhase = ''
      mkdir -p $out/bin
    '';

    installPhase = ''
      cp -r $src $out/bin/${name}
    '';
  };
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
      configDir = pkgs.stdenv.mkDerivation {
        pname = "eww-configfolder";
        version = "0.1";
        phases = [ "installPhase" ];

        src = ./config;

        # TODO: replace commands with actual paths to binaries
        installPhase = ''
          mkdir -p $out
          cp -r $src/* $out

          substituteInPlace $out/vars.yuck \
            --replace '@amixer@' '${pkgs.alsa-utils}/bin/amixer' \
            --replace '@eww@' '${package}/bin/eww' \
            --replace '@brightnessctl@' '${pkgs.brightnessctl}/bin/brightnessctl' \
            --replace '@reload_wm@' '${cfg.reload_cmd}' \
            --replace '@quit_wm@' '${cfg.quit_cmd}' \
            --replace '@lock_wm@' '${cfg.lock_cmd}' \
            --replace '@playerctl-py@' '${pylayerctl}/bin/pylayerctl' \
            --replace '@main_monitor@' '${builtins.toString cfg.main_monitor}'

          substituteInPlace $out/actions/actions.yuck \
            --replace '@playerctl@' '${pkgs.playerctl}/bin/playerctl' \
            --replace '@main_monitor@' '${builtins.toString cfg.main_monitor}'

          substituteInPlace $out/bar/bar.yuck \
            --replace '@main_monitor@' '${builtins.toString cfg.main_monitor}'

          substituteInPlace $out/scripts/popup \
            --replace '@rofi@' '${pkgs.rofi-wayland}/bin/rofi' \
            --replace '@terminal@' '${pkgs.kitty}/bin/kitty' \
            --replace '@pavucontrol@' '${pkgs.pavucontrol}/bin/pavucontrol'

          substituteInPlace $out/scripts/workspace \
            --replace '@socat@' '${pkgs.socat}/bin/socat' \
            --replace '@hyprctl@' '${pkgs.hyprland}/bin/hyprctl' \
            --replace '@jq@' '${pkgs.jq}/bin/jq'
        '';
      };
    };
  };
}
