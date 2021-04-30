{
  pkgs,
  username,
  background_image,
  ...
}:
{
  services.kdeconnect.enable = true;

  programs = {
    alacritty = {
      enable = true;
      settings = {
        font.normal.family = "iosevka";
        font.size = 12.0;
      };
    };
  };

  home.packages = with pkgs; [
    plasma-browser-integration
    flameshot
    rofi-pass
    rofi
    xclip
    libnotify
    latte-dock
  ];
}
