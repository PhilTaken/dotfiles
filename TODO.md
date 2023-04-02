# current TODOs:

- set up time machine backup on delta

- vim
    - disable ctags, don't use the tags much anyways (telscope grep usually does the trick)
    - mapping from the last comment in https://github.com/sindrets/diffview.nvim/issues/196 
    - fugitive plugin
    - change background with telescope open (it sets a background color, does not respect transparency)

- set up root gnupg home to use sops with yubikey on iso (x86-iso2)

- backup (important) syncthing folders locally and to b2
    - rclone / borg

- media container
    - -arr services for metadata

- slim down flake
    - stop abusing inputs (500+ MB just inputs)
    - try to prevent ifd modules

## general

- atuin sync server (backed up)
- utilize upload-daemon to cache the world on delta

- hyprland config
    - w/d for keybinds on laptop -> keycodes?

- declarative syncthing/mutagen config
- backup dns -> too tightly bound with delta -> no dns when not reachable (emergency)

- set up modules:
    - photoview -> librephotos
        - images in syncthing / seafile

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

- nebula
    - implement proper tagging
    - signing script with sops secrets
    - mobile device integration?

- caddy acme -> services.acme
    - removes need to compile caddy with cloudflare
    - better access to certificates from other services (unbound etc)

- http://consul.io?

## NVIM

### todo

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

## on hold

- centralize config more:
    - better ssh keys handling (public keys copied everywhere)
    - move gpg keys to some .nix file

- arm module (get rust running + spinning)
