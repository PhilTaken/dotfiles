# current TODOs:

- restructure network.nix
- network mask in network
- dont filter for hosts

- back up grocy

- alpha: dont use nix store cache from delta
- alpha: use delta as build server

- git fuzzy

- package racket-langserver
    - https://github.com/jeapostrophe/racket-langserver/blob/master/info.rkt

- Telescope git (merge conflicts / modified + new files)

- backup postgres database of nextcloud instance
- set up time machine backup on delta

- backup (important) syncthing folders locally and to b2
    - rclone / borg

- slim down flake
    - stop abusing inputs (500+ MB just inputs)
    - try to prevent ifd modules
    - npins: https://github.com/andir/npins

## general

- atuin sync server (backed up)

- hyprland config
    - w/d for keybinds on laptop -> keycodes?

- backup dns -> too tightly bound with delta -> no dns when not reachable (emergency)

- set up modules:
    - matrix-conduit
        - matrix bridges

    - roundcube mail client
    - radicale

    - modules for hardware config (keyboards / monitor setups etc.) to be used in wm/kanshi/etc.

    - hedgedoc
    - bookstack
    - snapcast server/clients

    - woodpecker module
        - ci/cd with hydra webhooks from gitea

- grafana config
    - todo: provisions

- nebula
    - implement proper tagging
    - signing script with sops secrets
    - mobile device integration?

- http://consul.io?

## NVIM

### todo

- neorg keybinds
- work with builtin `makeprg`
- diffviewopen telescope integration

### ideas

- zrythm
    - https://www.zrythm.org/en/index.html
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
- set up root gnupg home to use sops with yubikey on iso (x86-iso2)

