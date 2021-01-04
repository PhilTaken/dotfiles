{ pkgs, ... }:
{
  services.kanshi = {
    enable = true;
    profiles = {
      "dockstation" = {
        exec = "notify-send 'Kanshi switched to dockstation profile'";
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Dell Inc. DELL U2415 XKV0P05J16ZS";
            mode = "1920x1200";
            position = "0,1200";
          }
          {
            criteria = "Dell Inc. DELL U2415 XKV0P05J16YS";
            mode = "1920x1200";
            transform = "270";
            position = "1920,0";
          }
        ];
      };
      "default" = {
        exec = "notify-send 'Kanshi switched to default profile'";
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "1920x1080";
            position = "0,0";
          }
        ];
      };
      "at-home-1" = {
        exec = "notfiy-send 'Welcome home!'";
        outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080";
            position = "0,0";
          }
          {
            criteria = "Unknown 2460G4 0x0000C93A";
            mode = "1920x1080@119.98Hz";
            position = "1920,0";
          }
        ];
      };
      "at-home-2" = {
        exec = "notfiy-send 'Welcome home!'";
        outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080";
            position = "0,0";
          }
          {
            criteria = "Unknown TERRA 2455W 0x00000101";
            mode = "1920x1080";
            position = "1920,0";
          }
        ];
      };
    };
  };
}
