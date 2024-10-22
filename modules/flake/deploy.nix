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
      (builtins.mapAttrs (nodename: nodeconfig: {
          sshUser = "nixos";
          remoteBuild = true;
          # all network nodes should have a headscale ip
          hostname = lib.optionalString (lib.assertMsg (nodeconfig.network_ip ? "headscale") "node ${nodename} has no headscale ip, cannot deploy") nodeconfig.network_ip."headscale";
          profiles.system.path = (activateFor nodeconfig.system) self.nixosConfigurations.${nodename};
          sshOpts = ["-oControlMaster=no"];
        })
        net.nodes)
      // {
        # small nixos vm on mac
        # zetta = {
        #   hostname = "alice";
        #   sshUser = "root";
        #   remoteBuild = true;
        #   profiles.system.path = (activateFor "aarch64-linux") self.nixosConfigurations.zetta;
        # };
      };
  };
}
