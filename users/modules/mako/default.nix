{ pkgs, ... }:
{
  programs.mako = {
    enable = true;
    maxVisible = 5;
    defaultTimeout = 5000;
    font = "iosevka";
    backgroundColor = "#FFFFFF";
    textColor = "#000000";
    borderColor = "#000000";
    borderSize = 2;
    borderRadius = 4;
  };
}
