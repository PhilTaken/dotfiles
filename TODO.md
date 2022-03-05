# TODO:

## DNS


-> make wireguard network name configurable

- unbound on beta -> set dns in wireguard, tailscale

- generate all /etc/hosts entries from alpha/beta/... enabled servers?
    - very finicky, prone to issues

- improve docker service handling
    - maybe write custom module just for custom dockers
    - own, very simple take on docker-compose suited to my nixos needs

- generate traefik config from enabled options -> name, prefix, host etc.

- transfer torrents to beta for seeding
    - set up webinterface, automatic importing dir
        - move torrent file downloads there
        - download manager

## finances

- selfhosted preferably
- open source
- maybe free, not necessarily
    - good > free
- skrooge?

## general issues

- figure out why accessing influxdb doesnt work for desktop etc.
    - works with ssh tunnel?

- fix adguard home error

    ```nix
    services.adguardhome.settings = {
        dns = {
            bind_host = "SET_TO_YOUR_DNS_IP";
            bootstrap_dns = "SET_TO_YOUR_BOOTSTRAP_DNS";
        };
    };
    ```

    -> use this for all dns (unbound?)

- get waydroid working

## beta

- dns (see above)

- torrenting setup
    - music
    - lidarr/radarr/sonarr

- navidrome

- add bookstack service (native nixos module)

- backup (important) syncthing folders to b2
    - rclone / borg
    - set up payment for b2 (only first 10g free)

- hosted gitea -> dotfiles
    - gitea as main remote
    - push to gitlab from there? (with ci? / supervised?)

- photoview -> librephotos (docker in "./modules/hosts/server/default.nix")
    - images in syncthing

- set up hedgedoc

- enable ttrss

## wayland

- sway on nvidia (?)
    - newest beta driver
- plasma wayland
    - keep an eye on https://github.com/NixOS/nixpkgs/issues/134334

## alpha

- set up backing up database to beta

- move ttrss to beta + passthrough with nginx

- set up some custom dns routing for services hosted on beta
    - e.g. jellyfin.home, bookstack.home
    - overview website
        - e.g. heimdall

## nvim

- plugins
    - quickfix list
        - https://github.com/kevinhwang91/nvim-bqf
    - marks 
        - https://github.com/chentau/marks.nvim
    - autopairs (no matching ' in lisp files...)
    - commentary
        - tjdevries video

## Ideas

- expose all wireguard subnet adresses in config
    - useful in server module for webservices
    - useful for dns 
- define all ips/hostnames/ -> host specific settings in central config file to import into stuff

- webapps
    - roundcube mail client

- figure out why the mullvad app works but the plain config doesnt
    ```nix
    boot.kernelModules = [ "tun" ];

    # mullvad-daemon writes to /etc/iproute2/rt_tables
    networking.iproute2.enable = true;

    # See https://github.com/NixOS/nixpkgs/issues/113589
    networking.firewall.checkReversePath = "loose";
    ```
