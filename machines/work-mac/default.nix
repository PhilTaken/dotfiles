{
  pkgs,
  npins,
  ...
}: {
  imports = [
    ./philippherzog.nix
  ];

  stylix = {
    image = ../../images/vortex.png;
    base16Scheme = "${npins.base16}/base16/mocha.yaml";

    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        #package = pkgs.dejavu_fonts;
        #name = "DejaVu Sans Mono";
        package = pkgs.iosevka-comfy.comfy-duo;
        name = "Iosevka Comfy";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nixVersions.unstable;
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
