# TODO: polybar colors
# TODO: polybar modules separation / icons
{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.wms.bars.polybar;
in {
  options.phil.wms.bars.polybar = {
    enable = mkOption {
      description = "enable polybar module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    phil.wms.bars.barcommand = "systemctl --user restart polybar.service";

    services.polybar = {
      enable = true;
      package = pkgs.polybar.override {
        i3GapsSupport = true;
        githubSupport = true;
        pulseSupport = true;
      };
      config = {
        "bar/base" = {
          width = "100%:-24";
          height = 32;

          offset-x = 12;
          #offset-y = 5;

          tray-position = "right";
          override-redirect = false;
          #wm-restack = "i3";

          radius = 10;
          bottom = false;

          padding = 1;

          fixed-center = true;

          font-N = "<fontconfig pattern>;<vertical offset>";
          font-0 = "Iosevka;2";

          modules-left = "workspaces";
          modules-center = "date";
          modules-right = "volume network cpu ram";
        };

        "module/network" = {
          type = "internal/network";
          interface = "enp0s25";
          ping-interval = 3;
        };

        "module/date" = {
          type = "internal/date";
          interval = "1.0";
          time = "%I:%M %p";
          label = "%time%";

          format = "<label>";
          format-padding = 0;
          label-padding = 4;
        };

        "module/volume" = {
          type = "internal/pulseaudio";
          format-volume = "<label-volume>  ";

          label-volume = "%percentage%%";
          label-volume-padding = 1;

          format-muted = "<label-muted>";

          label-muted = "0% (muted)";
          label-muted-padding = 1;

          format-volume-padding = 0;
          format-muted-padding = 0;
          ramp-headphones-0 = " ";
        };


        "module/cpu" = {
          type = "internal/cpu";
          interval = "0.5";
          format = "<label>";
          label = "%percentage%%";
          label-padding = 1;
          format-prefix-padding = 1;
        };

        "module/ram" = {
          type = "internal/memory";
          interval = 3;
          format = "<label>";
          label = "%percentage_used%%";
          label-padding = 1;
          format-prefix-padding = 1;
        };

        "module/workspaces" = {
          type = "internal/i3";
          format = "<label-state> <label-mode>";
          index-sort = "true";
          wrapping-scroll = "false";
          strip-wsnumbers = "true";
          pin-workspaces = "true";
        };
      };
      script = "polybar base &";
    };
  };
}

