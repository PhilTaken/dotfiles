{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.openssh;
in {
  options.phil.server.services.openssh = {
    enable = mkEnableOption "openssh daemon";
    sshKeys = mkOption {
      description = "ssh keys for root user";
      type = types.listOf types.str;
      default = [
        # yubikey
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoABVjBx1az00D8EBjw9/NS9luqO2lN4Y87/2xsQqPTx9P7aXzfX53TwmU9Wpmp7qOIKykd8GSkBdCizMEzgaGmJl6+Di2GYvEfN0NrsLdBrjmIh7AQyR6UbY7qoTFjZ28864rk9QV9to2R1APL7o1wzdmCrFtTsemV+lw9MglqcPLT+ae2mba9fD84FFDmcSJMg5x1QHrO5GuWg/Ng7SE1eRhDbDmz66+HhdgvRRDJ9VwPGcH5ruXsDKvi/nrLVSxw7afvuM5KcNYoy+9CrA/N10cO5zdn4/q2DLYujkOvAucCDJ4bUEe8q6xEZw1LfCjKWIoFxzt+hetfkjS/Y3wWWTcHfcOx/BV6cOxyAFUGbu9RX/iUpyt8LAfjQv6L1zcD7vxYpfKz88jI/4zL7mHwILg+XQklBeiBsEQ4PyO1+4oIfuju241hVk+bFZYUD+AzzCNv7GKNNHe4aa4MWN6RLLhNxe9QlOTnsw0l2XNypr62Q1V8nxZkSY7mW8Hn0hLxTT82mTLuAff2yHPu+w+i0ELkk0BO28apxU1dPPbScHvojRlXTwIBvH3HN6TWdj2YnNFMdGvZgxxFNbi4l/7Gar1FKgi79KOwcm89ATmjONfbQMub+TaeBACefMZ9Q7uzbWeNO3mZpVA8nvM5eleqLemxYoeAQBuYjBjJlAHzQ== cardno:000614321676"
        # yubikey backup
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDUiT4SKpsN5RDkpTEYU+qjkYxMC9xPLJbWhYPVcMSJl4jvZ1/SfPpQidAmomkbxmeFZGgW3+8wG/gY9+0arNlQpV0g7O1fuc4pTn4SIAJRhDiypJwMmVClIbbCbIHAfcizrvXoNV0skTJgd2Tj11ixI7xhxa256lgMb4mCPLehcYSzhWywb1kcde9E05AFHgvHjG4XL6Z5WV7qB6BFP3vTPySNBR0+OhQXeQonL+3c/2B0BHOdsCcpr0281umoiw3ADcSc/qbon+bJXgAEUFXa+OHTapYsO9Jd7YjOG8De2DLorcrNJmYvUmuYkIVtkA6QfA+6/ZYGxuSbyKqi4uX5ZS4sKZJ9nJ1wQnL7ejSrnmH/O5b0rxxhe3Z2Hc6XYFpq66SCP7JhwUA3h+KOOG3T3QFZQ1Ygr5hkVGJgEWVbQ76FbLTrOrvR/TtWif7REYE6sXJNNFXl/eG5K5p65TVu7X7VCHlKIFmcL8nm1FXllOcXj92n/axgC+eZg5NnQN3JCwtLEwD7Z9mZ6B4Zt9BDFnHGE6ipThqtsCeOR0Zvh/Ezy4CWyEB+K1lqkGsSh8ff5Hg7a12OOSCeEmQwY/pCtyRgnDkL/Mbu52Pe1xoTSVzWqRRg7gG0A/vxPbWTFk9zAT497tadvMds5Aw7QINm8zsYTCRBIP641XHiTe7qeQ== openpgp:0x18E2D343"
      ];
    };
  };

  config = mkIf cfg.enable {
    # general open ssh config
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "yes";
      };
      authorizedKeysFiles = ["/etc/nixos/authorized-keys"];
    };

    # and set some ssh keys for root
    users.extraUsers.root.openssh.authorizedKeys.keys = cfg.sshKeys;
  };
}
