# TODO:

## general issues

- fix freezing desktop (gamma) (solved?)

- fix ssh_agent/gpg_agent interaction 
    - need to `export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)` in every shell currently
    - works on nixos-laptop

- fix adguard home error
    ```nix
    services.adguardhome.settings = {
        dns = {
            bind_host = "SET_TO_YOUR_DNS_IP";
            bootstrap_dns = "SET_TO_YOUR_BOOTSTRAP_DNS";
        };
    };
    ```

- get waydroid working

## DNS

- generate nginx config from enabled options -> name, prefix, host etc.
    - add to settings per service

-> make wireguard network name configurable

- generate all /etc/hosts entries from alpha/beta/... enabled servers?
    - very finicky, prone to issues

- improve docker service handling
    - maybe write custom module just for custom dockers
    - own, very simple take on docker-compose suited to my nixos needs

- transfer torrents to beta for seeding
    - set up webinterface, automatic importing dir
        - move torrent file downloads there
        - download manager? / auto move with command
    - mullvad on beta, torrenting just via mullvad interface


## beta

- dns (see above)

- torrenting setup
    - music
    - lidarr/radarr/sonarr, the whole stack

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
- re-enable ttrss

## alpha

- set up backing up database to beta

- move ttrss to beta + passthrough with nginx

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

- widgets to replace waybar / add functionality
  - https://github.com/elkowar/eww

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

## finances

- selfhosted preferably
- open source
- maybe free, not necessarily
    - good > free
- skrooge?
