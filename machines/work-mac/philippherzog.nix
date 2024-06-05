{pkgs, ...}: let
  darwin-fixes = import ./darwin-fixes.nix;
in {
  home-manager.users.philippherzog = {
    imports = [
      darwin-fixes.home-manager
    ];

    fonts.fontconfig.enable = true;
    disabledModules = ["targets/darwin/linkapps.nix"];

    launchd.agents.nebula = {
      enable = false;
      config = {
        ProgramArguments = ["sudo" "${pkgs.nebula}/bin/nebula" "-config" "/etc/nebula/config.yaml"];
        RunAtLoad = true;
        KeepAlive.SuccessfulExit = false;
        StandardErrorPath = "/tmp/nebula.job.err";
        StandardOutPath = "/tmp/nebula.job.out";
      };
    };
  };
}
