# alpha:
#   - can ping: alpha, gamma
#   - cant ping: beta
# beta:
#   - can ping: alpha, beta, gamma
#   - cant ping:
# gamma:
#   - can ping: alpha, gamma
#   - cant ping: beta

rec {
  alpha = {
    publicKey = "LDOII0S7OWakg4oDrC1wUCoM/YXq3wXTEjYoqBbI2Sk=";
    ownIPs = [ "10.100.0.1/24" ];
    allowedIPs = [ "10.100.0.0/24" ];
    endpoint = "148.251.102.93";
    port = 51821;
  };

  beta = {
    publicKey = "/DWBidRPbNdqBhXZJFGpD20K+Bs6ViEbq4DJOlw5f0U=";
    ownIPs = [ "10.100.0.2/24" ];
    allowedIPs = [ "10.100.0.0/32" ];
    endpoint = null;
  };

  gamma = {
    publicKey = "1w8CC/pEfXFPvdzyspDkuw/s8k2bkqAqk4KKg35IvQc=";
    ownIPs = [ "10.100.0.3/24" ];
    allowedIPs = [ "10.100.0.3/32" ];
    endpoint = null;
  };

  nixos-laptop = {
    publicKey = "Xbi0ylobPYxxcxCvxaJ2mvC2WqGlODnMkeIYPG9tlVo=";
    ownIPs = [ "10.100.0.4/24" ];
    allowedIPs = [ "10.100.0.4/32" ];
    endpoint = null;
  };
}
