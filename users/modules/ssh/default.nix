{ pgks, ... }:
{
  programs.ssh = {
    enable = true;
    # TODO completely replace these with gpg ssh agent
    #extraConfig = ''
    #    IdentityFile ~/.ssh/id_files/id_rsa_work
    #    IdentityFile ~/.ssh/id_files/id_rsa_private
    #    IdentityFile ~/.ssh/id_files/id_rsa_other
    #    IdentityFile ~/.ssh/id_rsa
    #'';
    matchBlocks = {
      "jureca" = {
        hostname = "jureca.fz-juelich.de";
        user = "herzog1";
        forwardAgent = true;
        forwardX11 = true;
      };
      "judac" = {
        hostname = "judac.fz-juelich.de";
        user = "herzog1";
        forwardAgent = true;
        forwardX11 = true;
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
        hostname = "192.168.8.148";
        user = "pi";
      };
      "justus-vm" = {
        hostname = "148.251.102.93";
        user = "nixos";
        forwardAgent = true;
      };
    };
  };
}
