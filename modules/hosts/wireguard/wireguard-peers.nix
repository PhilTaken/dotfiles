rec {
  alpha = {
    publicKey = "LDOII0S7OWakg4oDrC1wUCoM/YXq3wXTEjYoqBbI2Sk=";
    ownIPs = [ "10.100.0.1/24" ];
    allowedIPs = [ "10.100.0.0/24" ];
    endpoint = "148.251.102.93";
  };

  beta = {
    publicKey = "/DWBidRPbNdqBhXZJFGpD20K+Bs6ViEbq4DJOlw5f0U=";
    ownIPs = [ "10.100.0.2/24" ];
    allowedIPs = [ "10.100.0.2/32" ];
    #endpoint = "192.168.0.120";
  };

  gamma = {
    publicKey = "1w8CC/pEfXFPvdzyspDkuw/s8k2bkqAqk4KKg35IvQc=";
    ownIPs = [ "10.100.0.3/24" ];
    allowedIPs = [ "10.100.0.3/32" ];
  };

  nixos-laptop = {
    publicKey = "Xbi0ylobPYxxcxCvxaJ2mvC2WqGlODnMkeIYPG9tlVo=";
    ownIPs = [ "10.100.0.4/24" ];
    allowedIPs = [ "10.100.0.4/32" ];
  };

  delta = {
    publicKey = "598UtHyLn0L5ReObBtsT+UAJHtt7FtuFZiF5nRJ+nEg=";
    ownIPs = [ "10.100.0.5/24"];
    allowedIPs = [ "10.100.0.5/32"];
  };
}
