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

      delta = {
        hostname = "10.200.0.5";
        sshUser = "root";
        remoteBuild = true;
        profiles.system.path = (activateFor "x86_64-linux") self.nixosConfigurations.delta;
      };

      #epsilon = {
      #hostname = "192.168.0.130";
      #sshUser = "root";
      #profiles.system.path = (activateFor "x86_64-linux")  self.nixosConfigurations.epsilon;
      #};
    };
  };
}
