{ pgks, ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "jureca" = {
        hostname = "jureca.fz-juelich.de";
        user = "herzog1";
        #forwardAgent = true;
        #forwardX11 = true;
      };
      "judac" = {
        hostname = "judac.fz-juelich.de";
        user = "herzog1";
        #forwardAgent = true;
        #forwardX11 = true;
      };
      "work-pc" = {
        hostname = "iek8680.iek.kfa-juelich.de";
        user = "p.herzog";
        forwardAgent = true;
      };
      "vulkan" = {
        hostname = "iek8691.iek.kfa-juelich.de";
        user = "p.herzog";
        forwardX11 = true;
      };
      "mcserver" = {
        hostname = "192.168.192.42";
        user = "non-admin";
      };
      "router" = {
        hostname = "router.lan";
        user = "root";
      };
      "raspi" = {
        hostname = "192.168.8.236";
        user = "nixos";
      };
      "alpha" = {
        hostname = "148.251.102.93";
        user = "nixos";
        forwardAgent = true;
      };
      "alpha-root" = {
        hostname = "148.251.102.93";
        user = "root";
      };
      "zpi" = {
        hostname = "100.70.108.122";
        user = "ubuntu";
      };
      "zpi2" = {
        hostname = "134.94.149.164";
        user = "ubuntu";
      };
    };
  };
}
