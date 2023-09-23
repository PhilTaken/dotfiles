{pkgs, ...}: {
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nix.extraOptions = ''
    build-users-group = nixbld
    bash-prompt-prefix = (nix:$name)\040
    extra-nix-path = nixpkgs=flake:nixpkgs
    experimental-features = flakes nix-command
  '';

  programs.fish.enable = true;
  programs.zsh.enable = true;

  environment.shells = [
    "/run/current-system/sw/bin/nu"
    pkgs.nushell
  ];

  environment.systemPackages = [pkgs.nushell];

  users.users.philippherzog = {
    name = "philippherzog";
    description = "Philipp Herzog";
    home = "/Users/philippherzog";
    shell = pkgs.nushell;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
