{ pkgs, username, ... }:
{
  services.spotifyd = {
    enable = true;
    settings = (import ../../secret/spotify.nix {
      device_name = username;
    });
  };
}
