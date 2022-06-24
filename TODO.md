# TODO:

## general issues

- set up 
    - dns over tls

- set up modules:
    - dashboard (homer)
        - https://github.com/pborzenkov/nix-config/blob/master/nixos/machines/rock/dashboard.nix
        - https://github.com/bastienwirtz/homer/blob/main/docs/configuration.md

    - hydra module
        - ci/cd with hydra webhooks from gitea

    - -arr services for metadata

    - bookstack

    - photoview -> librephotos
        - images in syncthing / seafile

    - set up hedgedoc
    - re-enable ttrss


    - backup (important) syncthing folders to b2
        - rclone / borg


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


    - iris/mopidy (https://github.com/mopidy/mopidy-spotify/issues/110)

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

- nebula
    - implement proper tagging
    - signing script with sops secrets

- combine host + user config more (?) TODO: decide
    - enable appropriate configs for de/wm based on what is enabled on host

- http://consul.io?

## alpha

- back up databases to b2

## nvim

### TOOD

- window navigation
- work with builtin `makeprg`
- marks workflow
- quickfix list
- lsp definition/implementation
- scroll doc windows

### ideas

- https://github.com/extrawurst/gitui vs lazygit
- sk(im) sorter for telescope?
- plugins
    - symbol outlines (lsp)
        - https://github.com/simrat39/symbols-outline.nvim
    - quickfix list
        - https://github.com/kevinhwang91/nvim-bqf
    - marks
        - https://github.com/chentoast/marks.nvim
    - commentary
        - tjdevries video

## general Ideas

- flake templates for common languages

- matrix bridges for common services

- devdocs.io

- distributed file system
    - ceph
    - gluster
    - xtreemfs

## finances

- selfhosted
- skrooge?

udev script encrypted backup bitwarden
