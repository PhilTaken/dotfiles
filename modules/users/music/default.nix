{ pkgs, username, ... }:
{
  services.spotifyd = {
    enable = true;
    settings = (import ../../users/secret/spotify.nix {
      device_name = username;
    });
  };

  home.packages = with pkgs; [
    spotify-unwrapped

    ffmpeg
    playerctl
    pamixer
    vlc
    pavucontrol
    mpv
    #tauon
  ];
}
