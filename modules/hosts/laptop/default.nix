{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.laptop;
in
{
  options.phil.laptop = {
    enable = mkOption {
      description = "enable laptop module";
      type = types.bool;
      default = false;
    };

    # "wlp0s20f3" for nixos-laptop
    wirelessInterfaces = mkOption {
      description = "list of wireless interfaces";
      type = types.listOf types.str;
      default = [ ];
    };

    enableVPN = mkOption {
      description = "enable the mullvad vpn";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    sops.secrets.mullvad-privateKey = { };

    environment = {
      systemPackages = with pkgs; [
        powertop
        cmst # connman system tray
      ];
      sessionVariables.LIBVA_DRIVER_NAME = "iHD";
    };

    programs.light.enable = true;
    services.xserver.libinput.touchpad.accelProfile = "flat";

    services.connman = {
      enable = true;
      enableVPN = false;
      wifi.backend = "wpa_supplicant";
    };

    networking = {
      wg-quick.interfaces = mkIf (cfg.enableVPN) {
        mullvad = {
          address = [ "10.69.90.26/32" "fc00:bbbb:bbbb:bb01::6:5a19/128" ];
          dns = [ "193.138.218.74" ];
          privateKeyFile = config.sops.secrets.mullvad-privateKey.path;
          peers = [
            {
              publicKey = "vtqDtifokiHna0eBshGdJLedj/lzGW+iDvWKx+YjDFs=";
              allowedIPs = [ "0.0.0.0/0" "::0/0" ];
              endpoint = "193.27.14.98:51820";
            }
          ];
        };
      };
      wireless = {
        enable = true;
        userControlled.enable = true;
        interfaces = cfg.wirelessInterfaces;
      };
    };
  };
}

