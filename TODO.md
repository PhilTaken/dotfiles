# current TODOs:

- fix twisted build failure, reenable extrasensors for delta

- one psql database (per host?) for services
- rewrite ttrack in rust?

- set up time machine backup (samba) on delta
- back up grocy
- backup postgres database of nextcloud instance
- backup (important) syncthing folders locally and to b2
    - rclone / borg

- alpha: dont use nix store cache from delta
- alpha: use delta as build server

- git fuzzy

## ideas

- slim down flake
    - stop abusing inputs (500+ MB just inputs)
    - try to prevent ifd modules
    - npins: https://github.com/andir/npins

- atuin sync server (backed up)

- hyprland config
    - w/d for keybinds on laptop -> keycodes?

- set up modules:
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

- work with builtin `makeprg`

- zrythm
    - https://www.zrythm.org/en/index.html
- plugins
    - symbol outlines (lsp)
        - https://github.com/simrat39/symbols-outline.nvim
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

## on hold

- centralize config more:
    - better ssh keys handling (public keys copied everywhere)
        - ldap
    - move gpg keys to some .nix file
        - ldap?

- arm module (get rust running + spinning)
- set up root gnupg home to use sops with yubikey on iso (x86-iso2)
