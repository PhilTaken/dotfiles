{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.wms.bars.waybar;
in
{
  options.phil.wms.bars.waybar = {
    enable = mkOption {
      description = "enable waybar module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    programs.waybar = let
      css_file = ./style.css;
    in {
      enable = true;
      settings = [
        {
          layer = "top";
          position = "top";
          height = 15;
          modules-left = [ "idle_inhibitor" "sway/workspaces" "sway/mode" ];
          #modules-center = [ "custom/weather" ];
          modules-right = [ "pulseaudio" "battery" "memory" "network" "custom/vpn" "clock" "tray" ];
          modules = {
            "sway/workspaces" = {
              icon-size = 20;
              disable-scroll = true;
              all-outputs = false;
              format = "{name}";
            };
            "sway/mode".format = "<span style=\"italic\">{}</span>";
            "idle_inhibitor" = {
              format = "{icon}";
              format-icons.activated = "";
              format-icons.deactivated = "";
            };
            "tray".spacing = 10;
            "clock" = {
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
              format-alt = "{:%Y-%m-%d}";
            };
            "memory".format = "{}% ";
            "battery" = {
              states.warning = 30;
              states.critical = 15;
              format = "{capacity}% {icon}";
              format-icons = [ "" "" "" "" "" ];
            };
            "network" = {
              format-wifi = "{essid} ({signalStrength}%) ";
              format-ethernet = "{ifname} ";
              format-disconnected = "Disconnected ⚠";
              on-click = "cmst";
              tooltip-format = "{ipaddr}/{cidr}, {bandwidthUpBits} up, {bandwidthDownBits} down";
            };
            "pulseaudio" = {
              scroll-step = 5;
              format = "{volume}% {icon}";
              format-muted = "{icon}";
              format-icons = {
                headphones = "";
                default = [ "" "" ];
              };
              on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
              on-click-right = "pavucontrol";
            };
            "custom/vpn" = {
              interval = 1;
              return-type = "json";
              exec = pkgs.writeShellScript "vpn" ''
                wg >/dev/null 2>&1
                connected=$?

                if [ $connected -eq 1 ]; then
                icon=""
                class="connected"
                else
                icon=""
                class="disconnected"
                fi

                echo -e "{\"text\":\""$icon"\", \"tooltip\":\"Wireguard VPN ("$class")\", \"class\":\""$class"\"}"
              '';
              escape = true;
            };
            #"custom/weather" = {
            #interval = 900;
            #exec = "${weather_exec}";
            #};
          };
        }
      ];
      style = builtins.readFile css_file;
      #systemd.enable = true;
    };
  };
}

