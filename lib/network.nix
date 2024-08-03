config: lib: let
  inherit (builtins) elem concatLists isNull;
  net = config.phil.network;
  inherit (config.networking) hostName;

  node = net.nodes.${hostName};
  allServices = concatLists (lib.catAttrs "services" (builtins.attrValues net.nodes));
in {
  domainFor = host: "${host}.${net.tld}";

  nodeHas = lib.flip elem node.services;
  networkHas = lib.flip elem allServices;

  nodeHasPublicIp = !isNull node.public_ip;

  # generate ports with minimal overlap for your services
  # solely for internal use (port 80/443 -> proxy (nginx) -> port for service -> service)
  portFor = service: let
    rem = a: b: let
      div = builtins.div a b;
      mul = div * b;
    in
      a - mul;
    min_port = 1024;
    max_port = 49151;
    portRange = max_port - min_port + 1;

    raw_hash = builtins.hashString "sha256" service;

    hash = lib.fromHexString (builtins.substring 0 15 raw_hash);
  in
    (rem hash portRange) + min_port;
}
