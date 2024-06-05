{
  self,
  inputs,
  ...
}: let
  activateFor = system: inputs.deploy-rs.lib.${system}.activate.nixos;
  lib = inputs.nixpkgs.lib;
  net = (lib.evalModules {modules = [../../network.nix];}).config.phil.network;
in {
  flake = {
    # deploy config
    deploy.nodes =
      (builtins.mapAttrs (nodename: nodeconfig:
        lib.optionalAttrs (lib.assertMsg (nodeconfig.network_ip ? "headscale") "node ${nodename} has no headscale ip") {
          hostname = nodeconfig.network_ip."headscale";
          sshUser = "root";
          remoteBuild = true;
          profiles.system.path = (activateFor nodeconfig.system) self.nixosConfigurations.${nodename};
        })
      net.nodes)
      // {
        # small nixos vm on mac
        zetta = {
          hostname = "100.64.0.6";
          sshUser = "root";
          remoteBuild = true;
          profiles.system.path = (activateFor "aarch64-linux") self.nixosConfigurations.zetta;
        };
      };
  };
}
