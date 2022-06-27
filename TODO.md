# TODO:

## general issues

- write a readme file

- set up modules:
    - subsonic music streaming
    - torrenting container

    - dashboard (homer)
        - https://github.com/pborzenkov/nix-config/blob/master/nixos/machines/rock/dashboard.nix
        - https://github.com/bastienwirtz/homer/blob/main/docs/configuration.md

    - hydra module
        - ci/cd with hydra webhooks from gitea

    - backup (important) syncthing folders to b2
        - rclone / borg

    - xmonad (wip)
    - grocy

    - -arr services for metadata

    - matrix-conduit
        - matrix bridges

    - roundcube mail client
    - radicale

    - photoview -> librephotos
        - images in syncthing / seafile

    - ttrss
    - home-assistant
    - iris/mopidy (https://github.com/mopidy/mopidy-spotify/issues/110)

    - bspwm/awesomewm/river/hyprland
    - hedgedoc
    - bookstack
    - snapcast server/clients
    - pleroma


- work on eww bar config
    - workspaces
    - music popup?
    - css styling
    - onclick

- change module 
    - caddy acme -> services.acme
        - removes need to compile caddy with cloudflare
        - better access to certificates from other services (unbound etc)

- logging
    - grafana config
        - todo: provisions
    - extend vector to replace telegraf
        - geoip mapping ip adresses -> store in influxdb, visualize in grafana

- basic install script for custom image (basic partitioning -> back up all non-store files)

- nebula
    - implement proper tagging
    - signing script with sops secrets

- http://consul.io?

- nested flakes for better pinning
    - spacemacs/neovim/eww/spicetify/polymc

## NVIM

### todo

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
- devdocs.io
- distributed file system
    - ceph
    - gluster
    - xtreemfs
- udev script encrypted backup bitwarden to usb stick (bitwarden-cli)

## finances

- selfhosted
- skrooge?
