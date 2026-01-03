# current TODOs

- remove modules
    - nebula

- grafana
    - provisioned dashboards
    - grafana oncall -> alert/notify on 
        - unplanned downtime
        - failed backups
        - smart errors
        - zfs errors
        - failed systemd jobs

- auto nix-collect-garbage on beta, delta

- backups
    - fix nextcloud (turn maintenance on and off)
    - nextcloud postgres db
    - rclone / borg => rustic

- udev script encrypted backup bitwarden to usb stick (bitwarden-cli)
- set up root gnupg home to use sops with yubikey on iso (x86-iso2)

## other

- set up modules:
    - radicale for calendars
    - snapcast server/clients ?

## on hold

- centralize config more:
    - better ssh keys handling (public keys copied everywhere)
        - ldap?
        - kanidm!?
