# TODO:

- nvidia driver kinda meh 
    -> `sudo nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }, HDMI-1-1: nvidia-auto-select +3840+0 {ForceCompositionPipeline=On}"`

## IMPORTANT

- write an issue on serokell/deploy-rs about the dbus problem when trying to deploy / write an email

## main

- beta
    - set up nextcloud for small file hosting + floccus bookmark + browsersync, in container?
    - set up hedgedoc
    - set up vaultwarden
    - enable ttrss

- wayland
    - sway on nvidia (?) 
        - newest beta driver
    - plasma wayland
        - keep an eye on https://github.com/NixOS/nixpkgs/issues/134334

- alpha
    - set up revere proxy for all kinds of webservices on beta / gamma / etc.
    - set up backing up database to beta
    - move ttrss to beta + passthrough with nginx

- nvim
    - TODO: update config to 0.6
    - snippets
        - fortran 
            - module
    - plugins
        - quickfix list
            - https://github.com/kevinhwang91/nvim-bqf
        - marks 
            - https://github.com/chentau/marks.nvim
        - autopairs (no matching ' in lisp files...)
        - commentary

    - figure out how to get `pylsp` working with envs and stuff

# Ideas

- expose all wireguard subnet adresses in config
    - useful in server module for webservices
    - useful for dns 

- webapps
    - roundcube mail client
    - ihatemoney finance monitoring
