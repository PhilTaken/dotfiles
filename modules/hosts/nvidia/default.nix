{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.nvidia;
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{
  options.phil.nvidia = {
    enable = mkEnableOption "nvidia";
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
    environment.systemPackages = [ nvidia-offload ];

    nixpkgs.config = {
      allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "nvidia-x11"
          "nvidia-settings"
        ];
    };

    # https://wiki.hyprland.org/Nvidia/#how-to-get-hyprland-to-possibly-work-on-nvidia
    environment.variables = {
      GBM_BACKEND = "nvidia-drm";
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";

      WLR_NO_HARDWARE_CURSORS = "1";
      #WLR_BACKEND = "vulkan";

      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      MOZ_ENABLE_WAYLAND = "1";
      #NIXOS_OZONE_WL = "1";
      #CLUTTER_BACKEND = "wayland";
      #XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORM = "wayland";
      #GDK_BACKEND = "wayland";
    };

    services.xserver.screenSection = ''
      Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      Option         "AllowIndirectGLXProtocol" "off"
      Option         "TripleBuffer" "on"
    '';

    hardware = {
      nvidia = {
        open = false;
        modesetting.enable = true;
        package = config.boot.kernelPackages.nvidiaPackages.beta;
        nvidiaSettings = true;
        powerManagement.enable = false;
      };
      graphics = {
        extraPackages = with pkgs; [
          libvdpau-va-gl
          libva-vdpau-driver
          nvidia-vaapi-driver
        ];
        enable32Bit = true;
      };
    };

    environment.sessionVariables = {
      "__EGL_VENDOR_LIBRARY_FILENAMES" =
        "${config.hardware.nvidia.package}/share/glvnd/egl_vendor.d/10_nvidia.json";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GL_GSYNC_ALLOWED = "0";
      __GL_VRR_ALLOWED = "0";
      NVD_BACKEND = "direct";
    };

    boot = {
      kernelParams = lib.mkMerge [
        [
          "nvidia_drm.fbdev=1"
          "nvidia.NVreg_UsePageAttributeTable=1" # why this isn't default is beyond me.
        ]
        (lib.mkIf config.hardware.nvidia.powerManagement.enable [
          "nvidia.NVreg_TemporaryFilePath=/var/tmp" # store on disk, not /tmp which is on RAM
        ])
      ];
      blacklistedKernelModules = [ "nouveau" ];
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
