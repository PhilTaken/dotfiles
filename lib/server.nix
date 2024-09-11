{
  host,
  inputs,
  ...
}: let
  # allows value to overwrite enabled when specified explicitly
  defaultEnabled = builtins.mapAttrs (_: lib.mergeAttrs {enable = true;});
  inherit (inputs.nixpkgs) lib;
in {
  mkServer = services:
    host.mkBase [
      ({lib, ...}: {
        options.stylix = lib.mkOption {
          description = "placeholder module";
          type = lib.types.anything;
          default = null;
        };
      })
      ({lib, ...}: {
        config = {
          documentation.enable = false;

          zramSwap = {
            enable = true;
            algorithm = "zstd";
          };
          boot.kernel.sysctl = {
            "vm.swappiness" = 180;
            "vm.page-cluster" = 0;
          };

          phil = {
            # enable networking by default
            # TODO replace with headscale
            # nebula.enable = lib.mkDefault true;

            # no need for these on a server
            sound.enable = false;
            video.enable = false;
            yubikey.enable = false;

            server = let
              defaults = [
                "openssh"
                "fail2ban"
                #"telegraf"
                #"vector"
                "iperf"
              ];
            in {
              enable = true;
              services = builtins.foldl' lib.mergeAttrs {} (map
                (service:
                  if builtins.isAttrs service
                  then defaultEnabled service
                  else {"${service}".enable = true;})
                (defaults ++ services));
            };
          };
        };
      })
    ];
}
