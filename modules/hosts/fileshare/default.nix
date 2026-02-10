{ ... }:
{
  imports = [
    ./nfs.nix
    ./garage.nix
    ./samba.nix
    ./juicefs.nix
  ];
}
