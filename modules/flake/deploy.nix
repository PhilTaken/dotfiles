{
  self,
  inputs,
  ...
}: let
  activateFor = system: inputs.deploy-rs.lib.${system}.activate.nixos;
in {
  flake = {
    # deploy config
    deploy.nodes = {
      alpha = {
        hostname = "148.251.102.93";
        sshUser = "root";
        remoteBuild = true;
        profiles.system.path = (activateFor "x86_64-linux") self.nixosConfigurations.alpha;
      };

      beta = {
        hostname = "10.200.0.2";
        sshUser = "root";
        remoteBuild = true;
        profiles.system.path = (activateFor "aarch64-linux") self.nixosConfigurations.beta;
      };

      delta = {
        hostname = "10.200.0.5";
        sshUser = "root";
        remoteBuild = true;
        profiles.system.path = (activateFor "x86_64-linux") self.nixosConfigurations.delta;
      };

      zetta = {
        hostname = "alice";
        sshUser = "root";
        remoteBuild = true;
        profiles.system.path = (activateFor "aarch64-linux") self.nixosConfigurations.zetta;
      };
    };
  };
}
