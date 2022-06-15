# TODO:

## general issues

- set up modules:

    - dashboard (homer)
        - https://github.com/pborzenkov/nix-config/blob/master/nixos/machines/rock/dashboard.nix

    - gitea module
        - ci/cd with hydra/rain semi-automated with deploy-rs

    - matrix-conduit
    - home-assistant
    - roundcube mail client
    - grocy
    - pleroma
    - radicale
    - subsonic music streaming
    - snapcast server/clients

    - xmonad (wip)
    - xmobar
    - bspwm

    - seafile
    - iris/mopidy

- work on eww bar config
    - workspaces
    - music popup?
    - css styling
    - onclick

- logging
    - grafana config
        - todo: provisions
    - extend vector to replace telegraf
        - geoip mapping ip adresses -> store in influxdb, visualize in grafana

- basic install script for custom image (basic partitioning -> back up all non-store files)

- nested flakes for better pinning
    - spacemacs/neovim/eww/spicetify/polymc

- implement proper tagging for nebula
    - signing script with sops secrets

- combine host + user config more (?) TODO: decide
    - enable appropriate configs for de/wm based on what is enabled on host

- http://consul.io?

## delta

- -arr services for metadata

- bookstack service

- backup (important) syncthing folders to b2
    - rclone / borg

- photoview -> librephotos
    - images in syncthing / seafile

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

- distributed file system
    - ceph
    - gluster
    - xtreemfs

## finances

- selfhosted
- skrooge?
