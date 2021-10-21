# TODO

- wayland
    - sway on nvidia (?) 
        - newest beta driver
    - plasma wayland
        - keep an eye on https://github.com/NixOS/nixpkgs/issues/134334

- alpha
    - set up influxdb2
    - set up grafana monitoring
    - set up revere proxy for all kinds of webservices on beta / gamma / etc.
    - set up backing up database to beta
    - move ttrss to beta + passthrough with nginx

- beta
    - set up sensor + logging to grafana
    - set up nextcloud for small file hosting + floccus bookmark + browsersync, in container?
    - set up hedgedoc
    - set up vaultwarden
    - enable ttrss

- all hosts
    - set up monitoring / logging of system stats to grafana (on alpha)

- nvim
    - disable tab/shift-tab completion, enter for selection. use the original vim ways of <c-n>, <c-p> and <c-y>
    - learn more `:h ins-complete` bindings

# WIP

# Ideas

- expose all wireguard subnet adresses in config
    - useful in server module for webservices
    - useful for dns 

- roundcube mail client
