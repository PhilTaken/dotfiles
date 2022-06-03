{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.nebula;
  peers = import ./nebula-peers.nix;
  networkName = "milkyway";
  hostname = config.networking.hostName;
  hostMap = {
    "10.200.0.1" = [ "148.251.102.93:4242" ];
  };
  owner = config.systemd.services."nebula@${networkName}".serviceConfig.User or "root";
  sopsFile = ../../../sops/nebula.yaml;
  lighthouses = if builtins.elem hostname cfg.lighthosts then [] else builtins.attrNames hostMap;

  any = { port = "any"; proto = "any"; host = "any"; };

in {
  options.phil.nebula = {
    enable = mkOption {
      description = "enable nebula module";
      type = types.bool;
      default = false;
    };

    lighthosts = mkOption {
      description = "list of lighthouses";
      type = types.listOf types.str;
      default = [ "alpha" ];
    };
  };

  config = mkIf (cfg.enable) {

    sops.secrets.ca = {
      inherit owner sopsFile;
    };
    sops.secrets."${hostname}-key" = {
      inherit owner sopsFile;
    };
    sops.secrets."${hostname}-crt" = {
      inherit owner sopsFile;
    };

    services.nebula.networks."${networkName}" = {
      inherit (cfg) enable;
      inherit lighthouses;

      ca = config.sops.secrets.ca.path;
      key = config.sops.secrets."${hostname}-key".path;
      cert = config.sops.secrets."${hostname}-crt".path;

      isLighthouse = builtins.elem hostname cfg.lighthosts;
      staticHostMap = hostMap;
      firewall.inbound = [ any ];
      firewall.outbound = [ any ];
    };
  };
}

