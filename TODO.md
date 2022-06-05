# TODO:

## general issues

- work on eww bar config
    - workspaces
    - music popup?
    - css styling
    - onclick

- set up modules:
    - logging
        - graylog module
        - syslog configs
        - vector.dev ?
    - gitea module
        - ci/cd with hydra/rain semi-automated with deploy-rs
    - set up matrix server module
        - matrix-conduit
    - home-assistant
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

- basic install script for custom image (basic partitioning -> back up all non-store files)

- nested flakes for better pinning
    - spacemacs/neovim/eww/spicetify/polymc

- implement proper tagging for nebula

- combine host + user config more (?) TODO: decide
    - enable appropriate configs for de/wm based on what is enabled on host

- consul?

## DNS

- "global" network definitions file
    - expose all wireguard subnet adresses in config
        - useful in server module for webservices
        - useful for dns

    - define all ips/hostnames/ -> host specific settings in central config file to import into stuff

- generate nginx config from enabled options -> name, prefix, host etc.
    - add to settings per service

- transfer torrents to beta for seeding
    - set up webinterface, automatic importing dir
        - download manager? / auto move with command?

## beta

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

- webapps
    - roundcube mail client

- distributed file system
    - ceph
    - gluster
    - xtreemfs

## finances

- selfhosted preferably
- open source
- maybe free, not necessarily
    - good > free
- skrooge?
