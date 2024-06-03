# current TODOs:

- fix keycloak configs
- mealie module
- set up audiobookshelf
- atuin sync server (backed up)

- backups
    - fix nextcloud backups (turn maintenance on and off)
    - backup nextcloud postgres db
    - rclone / borg => rustic

- fix twisted build failure, reenable extrasensors for delta
    - otherwise riir

- improve network.nix
    - module?

- setup paperless
    - + backup

- properly generate zellij config in nix (home manager)

- one psql database (per host?) for services

- grafana config
    - todo: provisions

- monitor drives
    - zpool status
    - smart status

- udev script encrypted backup bitwarden to usb stick (bitwarden-cli)
- set up root gnupg home to use sops with yubikey on iso (x86-iso2)

## other

- set up modules:
    - radicale

    - modules for hardware config (keyboards / monitor setups etc.) to be used in wm/kanshi/etc.

    - hedgedoc
    - snapcast server/clients

- nebula
    - implement proper tagging
    - signing script with sops secrets
    - mobile device integration?

- nvim plugins
    - marks
        - https://github.com/chentoast/marks.nvim
    - commentary
        - tjdevries video
    - run scripts
        - https://github.com/stevearc/overseer.nvim

- gromit-mpx

## on hold

- centralize config more:
    - better ssh keys handling (public keys copied everywhere)
        - ldap?
    - move gpg keys to some .nix file
        - ldap?
