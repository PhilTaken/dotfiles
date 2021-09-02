{ pgks, ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "jureca" = {
        hostname = "jureca.fz-juelich.de";
        user = "herzog1";
        forwardAgent = true;
        #forwardX11 = true;
      };
      "judac" = {
        hostname = "judac.fz-juelich.de";
        user = "herzog1";
        forwardAgent = true;
        #forwardX11 = true;
      };
      "work-pc" = {
        hostname = "iek8680.iek.kfa-juelich.de";
        user = "p.herzog";
        forwardAgent = true;
        forwardX11 = true;
      };
      "vulkan" = {
        hostname = "iek8691.iek.kfa-juelich.de";
        user = "p.herzog";
        forwardX11 = true;
        forwardAgent = true;
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
        hostname = "192.168.8.14";
        user = "pi";
      };
      "alpha" = {
        hostname = "148.251.102.93";
        user = "nixos";
        forwardAgent = true;
      };
      "alpha-root" = {
        hostname = "148.251.102.93";
        user = "root";
        forwardAgent = true;
      };
      "zpi" = {
        hostname = "134.94.149.163";
        user = "ubuntu";
        forwardAgent = true;
      };
      "zpi2" = {
        hostname = "134.94.149.164";
        user = "pi";
        forwardAgent = true;
      };
    };
  };
}
