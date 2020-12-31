{ pkgs, ...}: {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ];
    shell = pkgs.zsh;
}
