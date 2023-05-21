{
  config,
  lib,
  ...
}: let
  l = builtins // lib;
  inherit (l.types) bool;
  inherit (l) mkOption;
in {
  options = {
    services.gmediarender = {
      openFirewall = mkOption {
        type = bool;
        default = true;
        description = "wether to open the necessary firewall ports";
      };
    };
  };

  config = {
    # mkIf cfg.enable {
    #networking.firewall.allowedTCPPorts = optionals cfg.openFirewall [ 49494 ];
    #networking.firewall.allowedUDPPorts = optionals cfg.openFirewall [ 1900 ];

    networking.firewall.allowedUDPPorts = [1900];
    networking.firewall.allowedTCPPorts = [32827];
  };
}
