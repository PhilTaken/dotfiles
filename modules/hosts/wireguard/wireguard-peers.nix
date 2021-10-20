rec {
  alpha = {
    publicKey = "LDOII0S7OWakg4oDrC1wUCoM/YXq3wXTEjYoqBbI2Sk=";
    ownIPs = [ "fd2e:6bab:852b:1:1::1/72" ];
    endpoint = "148.251.102.93";
    port = 51820;
  };

  beta = {
    publicKey = "/DWBidRPbNdqBhXZJFGpD20K+Bs6ViEbq4DJOlw5f0U=";
    ownIPs = [ "fd2e:6bab:852b:2:1::1/72" ];
  };

  gamma = {
    publicKey = "1w8CC/pEfXFPvdzyspDkuw/s8k2bkqAqk4KKg35IvQc=";
    ownIPs = [ "fd2e:6bab:852b:2:2::1/72" ];
  };

  nixos-laptop = {
    publicKey = "Xbi0ylobPYxxcxCvxaJ2mvC2WqGlODnMkeIYPG9tlVo=";
    ownIPs = [ "fd2e:6bab:852b:2:3::1/72" ];
  };
}
