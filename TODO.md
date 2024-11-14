# current TODOs

- grafana
    - uids for datasources
    - provisioned dashboards
    - grafana oncall -> alert/notify on 
        - unplanned downtime
        - failed backups
        - smart errors
        - zfs errors
        - failed systemd jobs

- auto nix-collect-garbage on beta, delta
- set up audiobookshelf

- backups
    - paperless
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
    - audiobookshelf for podcasts

    - radicale + ente / immich
        - to replace nextcloud
        - maybe nextcloud memories is fine for now

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
        - kanidm!
