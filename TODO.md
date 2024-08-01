# current TODOs

- auto nix-collect-garbage on beta, delta

- utility to check port, ip, uid overlap

- utility functions in network.nix
    - get fqdn from host 
    - assertions about something being defined for the network
    - assertions about something being defined on the same host

- tmux config
    - keybinds / popups for pri/sri/twm integration
        - fuzzy finder
            - with preview if there is an existing session

- set up ente.io docker containers
- set up audiobookshelf
- setup paperless
    - + backup

- improve sketchybar
    - module? -> requires nix-darwin service ...

- backups
    - fix nextcloud (turn maintenance on and off)
    - nextcloud postgres db
    - rclone / borg => rustic

- one psql database (per host?) for services?

- grafana config -> dashboard provisions

- monitor drives
    - zpool status
    - smart status

- udev script encrypted backup bitwarden to usb stick (bitwarden-cli)
- set up root gnupg home to use sops with yubikey on iso (x86-iso2)

## other

- set up modules:
    - bookstack
    - paperless
    - audiobookshelf

    - radicale
        - to replace nextcloud
    - modules for hardware config (keyboards / monitor setups etc.) to be used in wm/kanshi/etc.

    - hedgedoc
    - snapcast server/clients

- deprecate nebula

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
