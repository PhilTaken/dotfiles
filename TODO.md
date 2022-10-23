# TODO:

- hyprland config
    - w/d for keybinds -> keycodes/letter?
- eww config
    - workspaces (theme / colors)
    - css styling
    - music popup?
- declarative syncthing/mutagen config

- setup script
    - akin to https://github.com/cleverca22/nix-tests/blob/master/kexec/justdoit.nix
- age-key script + master age-key backup
- auto import gpg public key
- ssh known hosts

- delta as dns on nebula
    - set on all servers

- better ssh keys handling (public keys copied everywhere)

- fix loki: unknown variant `loki`, expected `unit_test` for key `sinks.loki`

## general issues

- set up modules:
    - arm module (get rust running + spinning)

    - torrenting container
    - -arr services for metadata

    - backup (important) syncthing folders locally and to b2
        - rclone / borg

    - dashboard (homer)
        - https://github.com/pborzenkov/nix-config/blob/master/nixos/machines/rock/dashboard.nix
        - https://github.com/bastienwirtz/homer/blob/main/docs/configuration.md

    - photoview -> librephotos
        - images in syncthing / seafile

    - hydra module
        - ci/cd with hydra webhooks from gitea

    - navidrome music streaming

    - shiori

    - xmonad (wip)
    - xbrowsersync
    - grocy

    - matrix-conduit
        - matrix bridges

    - roundcube mail client
    - radicale

    - modules for hardware config (keyboards / monitor setups etc.) to be used in wm/kanshi/etc.

    - ttrss
    - iris/mopidy (https://github.com/mopidy/mopidy-spotify/issues/110)

    - bspwm/awesomewm/river
    - hedgedoc
    - bookstack
    - snapcast server/clients
    - pleroma
    - shiori bookmark manager

    - github actions + cachix
    - build server for low-powered laptop

- change module 
    - caddy acme -> services.acme
        - removes need to compile caddy with cloudflare
        - better access to certificates from other services (unbound etc)

- logging
    - grafana config
        - todo: provisions
    - extend vector to replace telegraf
        - geoip mapping ip adresses -> store in influxdb, visualize in grafana


- nebula
    - implement proper tagging
    - signing script with sops secrets

- caddy acme -> services.acme
    - removes need to compile caddy with cloudflare
    - better access to certificates from other services (unbound etc)

- http://consul.io?

## NVIM

### todo

- reload wip plugin files (plenary on special runtimepath match?)
- window navigation
- work with builtin `makeprg`
- lsp implementation
- diffviewopen telescope integration
- marks workflow

### ideas

- nvim heirline, other plugins (see tabstash)
- nvim highlight for folds

- zrythm
    - https://www.zrythm.org/en/index.html
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
    - run scripts
        - https://github.com/stevearc/overseer.nvim

## general Ideas

- flake templates for common languages
- distributed file system
    - ceph
    - gluster
    - xtreemfs
- udev script encrypted backup bitwarden to usb stick (bitwarden-cli)
- gromit-mpx

## finances

- selfhosted
- skrooge?

# for newer setups

- basic install script for custom image (basic partitioning -> back up all non-store files)
- declarative syncthing config
- setup script
    - akin to https://github.com/cleverca22/nix-tests/blob/master/kexec/justdoit.nix
- age-key script + master age-key backup
- auto import gpg public key
- ssh known hosts

