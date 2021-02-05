{ pkgs, ...}: {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "docker" ];
    shell = pkgs.zsh;
}
