rec {
  server = {
    publicKey = "";
    allowedIPs = [ "0.0.0.0/0" "::/0" ];
    endpoint =
  };
  clients = let
    endpoint = let
      ipv4 = builtins.head server.address;
      port = server.listenPort;
    in "${ipv4}:${port}";
  in {
    beta = {

    };

    gamma = {

    };

    nixos-laptop = {

    };
  };
}
