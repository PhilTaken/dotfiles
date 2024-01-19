{pkgs, ...}: {
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nix.extraOptions = ''
    build-users-group = nixbld
    bash-prompt-prefix = (nix:$name)\040
    extra-nix-path = nixpkgs=flake:nixpkgs
    experimental-features = flakes nix-command
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  programs.fish.enable = true;
  programs.zsh.enable = true;

  environment.shells = [
    "/run/current-system/sw/bin/nu"
    "/run/current-system/sw/bin/fish"
    pkgs.nushell
    pkgs.zsh
  ];

  environment.systemPackages = [pkgs.nushell pkgs.openssh];

  users.users.philippherzog = {
    name = "philippherzog";
    description = "Philipp Herzog";
    home = "/Users/philippherzog";
    shell = pkgs.fish;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  security.pam.enableSudoTouchIdAuth = true;

  system.defaults = {
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    screencapture.location = "~/Pictures/screenshots";
  };
}
