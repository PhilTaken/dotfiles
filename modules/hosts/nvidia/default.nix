{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.nvidia;
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in {
  options.phil.nvidia = {
    enable = mkEnableOption "nvidia";
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = lib.mkDefault ["nvidia"];

    phil.video.driver = lib.mkDefault "nvidia";

    environment.systemPackages = [nvidia-offload];

    boot.kernelParams = ["nvidia_drm.fbdev=1"];

    hardware = {
      nvidia = {
        open = false;
        modesetting.enable = true;
        package = config.boot.kernelPackages.nvidiaPackages.beta;
      };
      graphics = {
        extraPackages = with pkgs; [libvdpau-va-gl vaapiVdpau];
        #extraPackages32 = with pkgs; [ libvdpau-va-gl vaapiVdpau ];
      };
    };

    # environment.etc."egl/egl_external_platform.d/10_nvidia_wayland.json".text = ''
    #     {
    #       "file_format_version" : "1.0.0",
    #       "ICD" : {
    #           "library_path" : "${pkgs.egl-wayland}/lib/libnvidia-egl-wayland.so"
    #       }
    #   }
    # '';

    # environment.etc."glvnd/egl_vendor.d/10_nvidia.json".text = ''
    #   {
    #     "file_format_version" : "1.0.0",
    #     "ICD" : {
    #       "library_path" : "${pkgs.linuxPackages_latest.nvidia_x11}/lib/libEGL_nvidia.so"
    #     }
    #   }
    # '';
  };
}
