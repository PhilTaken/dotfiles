# current TODOs:

## delta

- monitor drives
    - zpool status
    - smart status

- backups of important data
- fix twisted build failure, reenable extrasensors for delta

- setup paperless
    - +backup IMPORTANT
- atuin sync server (backed up)
- vaultwarden selfhosted (backed up, rendundancy?)
- properly generate zellij config in nix (home manager)

- one psql database (per host?) for services
- backup postgres database of nextcloud instance
- backup (important) syncthing folders locally and to b2
    - rclone / borg => rustic

- alpha: dont use nix store cache from delta
- alpha: use delta as build server

- grafana config
    - todo: provisions

- udev script encrypted backup bitwarden to usb stick (bitwarden-cli)
- set up root gnupg home to use sops with yubikey on iso (x86-iso2)

## other

- hyprland config
    - w/d for keybinds on laptop -> keycodes?
        - implemented (state 2024-03-19)

- set up modules:
    - radicale

    - modules for hardware config (keyboards / monitor setups etc.) to be used in wm/kanshi/etc.

    - hedgedoc
    - snapcast server/clients

    - woodpecker module
        - ci/cd with hydra webhooks from gitea

- nebula
    - implement proper tagging
    - signing script with sops secrets
    - mobile device integration?

- http://consul.io for services?

- nvim plugins
    - symbol outlines (lsp)
        - https://github.com/simrat39/symbols-outline.nvim
    - marks
        - https://github.com/chentoast/marks.nvim
    - commentary
        - tjdevries video
    - run scripts
        - https://github.com/stevearc/overseer.nvim

- flake templates for common languages

- distributed file system
    - ceph
    - gluster
    - xtreemfs

- gromit-mpx

## on hold

- centralize config more:
    - better ssh keys handling (public keys copied everywhere)
        - ldap?
    - move gpg keys to some .nix file
        - ldap?
