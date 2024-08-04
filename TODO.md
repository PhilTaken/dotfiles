# current TODOs

- auto nix-collect-garbage on beta, delta
- fix nix-build dns on delta when building 

- portunus -> openldap for user sync

- set up ente.io docker containers
- set up audiobookshelf
- setup paperless
    - + backup

- backups
    - fix nextcloud (turn maintenance on and off)
    - nextcloud postgres db
    - rclone / borg => rustic

- grafana config -> dashboard provisions

- monitor drives
    - zpool status
    - smart status

- udev script encrypted backup bitwarden to usb stick (bitwarden-cli)
- set up root gnupg home to use sops with yubikey on iso (x86-iso2)

## other

- set up modules:
    - paperless-ngx
    - audiobookshelf for podcasts

    - radicale + ente / immich
        - to replace nextcloud

    - snapcast server/clients

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
