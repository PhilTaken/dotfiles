{ pkgs, ... }: {
  accounts.email.accounts = {
    gmail = {
      realName = "Philipp Herzog";
      address = "philippherzog07@gmail.com";
      userName = "philippherzog07@gmail.com";
      flavor = "gmail.com";
      passwordCommand = "gopass show --password mail/gmail/philippherzog07@gmail.com";
      imap = {
        host = "imap.gmail.com";
        port = 993;
      };
      smtp = {
        host = "smtp.gmail.com";
        port = 465;
        tls.enable = true;
      };
      neomutt.enable = true;
      notmuch.enable = true;
      lieer.enable = true;
      lieer.sync.enable = true;
      primary = true;
    };

    arbeit = {
      realName = "Philipp Herzog";
      address = "p.herzog@fz-juelich.de";
      userName = "p.herzog";
      flavor = "plain";
      passwordCommand = "gopass show --password mail/arbeit/p.herzog@fz-juelich.de";
      imap = {
        host = "imap.fz-juelich.de";
        port = 993;
      };
      smtp = {
        host = "mail.fz-juelich.de";
        port = 587;
        tls.enable = true;
      };
      neomutt.enable = true;
      notmuch.enable = true;
    };
  };

  programs = {
    #lieer.enable = true;
    #notmuch.enable = true;
    #afew.enable = true;
    #neomutt = {
      #enable = true;
    #};
  };
}
