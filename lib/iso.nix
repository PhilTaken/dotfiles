{ host
, pkgs
, ...
}:

let
  nixos = {
    name = "nixos";
    groups = [ "wheel" ];
    shell = pkgs.zsh;
    uid = 1001;
  };
in {
  mkIso = hostName: util.host.mkHost {
    users = [ nixos ];
    systemConfig = {
      core = { inherit hostName; };
      wireguard.enable = false;
      server.services.openssh.enable = true;
    };
    extraimports = [ baseInstallerImport ];
  };
}
