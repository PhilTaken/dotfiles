# TODO:

- split server up into parts

## IMPORTANT


## main

- beta
    - photoview -> librephotos (docker in "./modules/hosts/server/default.nix")
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

# Ideas

- expose all wireguard subnet adresses in config
    - useful in server module for webservices
    - useful for dns 

- webapps
    - roundcube mail client
    - ihatemoney finance monitoring
