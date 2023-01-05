{
  # TODO: add install script (+ binary cache?)
  mkIso = {
      nixpkgs
    , system
    , hostName
    , lib ? nixpkgs.lib
    , pkgs ? import nixpkgs { inherit system; }
    , ... }:
  lib.nixosSystem {
    inherit system pkgs;

    modules = [
      ../modules/hosts/server/openssh.nix
      "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
      ({ pkgs, ...}: {
        phil.server.services.openssh.enable = true;
        networking = { inherit hostName; };
        time.timeZone = "Europe/Berlin";

        programs = {
          mtr.enable = true;
          zsh.enable = true;
        };

        users.users.nixos = {
          name = "nixos";
          extraGroups = [ "wheel" ];
          shell = pkgs.zsh;
        };

        environment.systemPackages = with pkgs; [
          vim
          git
          git-crypt
          cryptsetup
          hwinfo
          htop
          magic-wormhole
        ];
      })
    ];
  };
}
