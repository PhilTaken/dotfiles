# TODO:

centralize config more:
    - better ssh keys handling (public keys copied everywhere)
    - move gpg keys to some .nix file

- set up root gnupg home to use sops with yubikey on iso (x86-iso2)

## general

- setup ci/flake update via hercules-ci on delta
- upload-daemon to cache the world on delta

- generate ssh targets from network file

- hyprland config
    - w/d for keybinds on laptop -> keycodes?

- eww config
    - bar styling
    - bar modules
    - music popup?
    - bluetooth/wifi/airplane mode

- declarative syncthing/mutagen config

- backup dns -> too tightly bound with delta -> no dns when not reachable (emergency)

- set up modules:
    - arm module (get rust running + spinning)

    - backup (important) syncthing folders locally and to b2
        - rclone / borg

    - photoview -> librephotos
        - images in syncthing / seafile

    - torrenting container
    - -arr services for metadata

    - xmonad (wip)
    - grocy

    - matrix-conduit
        - matrix bridges

    - roundcube mail client
    - radicale

    - modules for hardware config (keyboards / monitor setups etc.) to be used in wm/kanshi/etc.

    - ttrss

    - bspwm/awesomewm/river
    - hedgedoc
    - bookstack
    - snapcast server/clients

    - woodpecker module
        - ci/cd with hydra webhooks from gitea


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
- diffviewopen telescope integration
- marks workflow

### ideas

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
    - akin to https://github.com/cleverca22/nix-tests/blob/master/kexec/justdoit.nix
    - disko

    - age-key script + master age-key backup

    - auto import gpg public key
    - ssh known hosts
