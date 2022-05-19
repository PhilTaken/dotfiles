# TODO:

- set up xmonad
- combine host + user config more 
    - enable appropriate configs for de/wm based on what is enabled on host

## general issues

- fix freezing desktop (gamma) (solved?)

- fix ssh_agent/gpg_agent interaction 
    - GNOME issue (!), works under kde plasma & i3 ..?
    - need to `export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)` in every shell currently

- get waydroid working

- wireguard / headscale ?
    - other, more direct approach than road-warrior wireguard with all traffic via external vps

## DNS

- "global" network definitions file

- generate nginx config from enabled options -> name, prefix, host etc.
    - add to settings per service

-> make wireguard network name configurable

- transfer torrents to beta for seeding
    - set up webinterface, automatic importing dir
        - move torrent file downloads there
        - download manager? / auto move with command
    - mullvad on beta, torrenting just via mullvad interface

## beta

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

- photoview -> librephotos
    - images in syncthing

- set up hedgedoc
- re-enable ttrss

## alpha

- set up backing up database to beta or b2 directly
- move ttrss to beta + passthrough with caddy

## nvim

- sk(im) sorter for telescope?

- plugins
    - symbol outlines (lsp)
        - https://github.com/simrat39/symbols-outline.nvim
    - quickfix list
        - https://github.com/kevinhwang91/nvim-bqf
    - marks 
        - https://github.com/chentau/marks.nvim
    - commentary
        - tjdevries video

## Ideas

- station application
    - https://getstation.com/

- devdocs api docs
    - devdocs.io

- widgets to replace waybar / add functionality
  - https://github.com/elkowar/eww

- expose all wireguard subnet adresses in config
    - useful in server module for webservices
    - useful for dns 
- define all ips/hostnames/ -> host specific settings in central config file to import into stuff

- webapps
    - roundcube mail client

## finances

- selfhosted preferably
- open source
- maybe free, not necessarily
    - good > free
- skrooge?
