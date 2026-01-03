# My NixOS dotfiles

> Always remember that you are absolutely unique. Just like everyone else.
>
> --- Margaret Mead

## Introduction / Foreword

These dotfiles, as they are laid out here, are the culmination of over three years of work, tinkering and experimentation.  
Going back and forth, trying out different strategies, failing and succeeding.

This current state, too, is just a snapshot in time - a snowflake, frozen in time. Stateless and stateful all at once.

# How to Install

if you are *rebooted into nixos iso image via web console / ssh* and have *set up the configuration for a new host*, then follow these instructions:

## set up the drive

```
$ nix --extra-experimental-features "nix-command flakes" build github:philtaken/dotfiles#nixosConfigurations.beta.config.system.build.diskoScript
$ sudo ./result
```

## generate a new age key

```
$ sudo mkdir -p /mnt/var/lib/sops-nix/
$ nix --extra-experimental-features "nix-command flakes" shell nixpkgs#age 
$ sudo age-keygen -o /mnt/var/lib/sops-nix/key.txt
```

update sops secrets with new public key, make sure all secrets are generated, for example

- nebula key

maybe double-check your hardware config on the vm with a quick
```
nixos-generate-config --root /mnt --no-filesystems --dir .
cat hardware-configuration.nix
```

mistakes have been made before (not speaking from personal experience)...

## finish up the installation

```
$ sudo nixos-install --root /mnt --flake github:philtaken/dotfiles#beta
```

# Details

## Basic Structure

These configuration files describe a number of systems as well as their interaction.
There are "servers" which can be thought of in the traditional sense - a highly available platform running a selection of services.
And there are "hosts", user-facing machines with graphical environments, meant for interactive use and not always powered on.
Both of these will hereafter be referred to as a "setup".

### Definition

Every setup consists of either two or three parts:

1. a hardware-specific machine configuration in [./machines/](./machines)
2. host-specific modules, defined under [./modules/hosts/](./modules/hosts)
3. (optional) a home-manager configuration based off of user-specific modules defined under [./modules/users](./modules/users)

These three parts are combined using helper methods defined under [./lib/server.nix](./lib/server.nix), [./lib/host.nix](./lib/host.nix) and [./lib/user.nix](./lib/user.nix).

[./network.nix](./network.nix) defines what services are running where for servers specifically.
This file also serves as means to generate DNS entries for [Unbound](./modules/hosts/server/unbound.nix), reverse proxy entries for [Caddy](./modules/hosts/server/caddy/default.nix), a basic ip lookup table for [nfs mounts](./modules/hosts/fileshare/default.nix) and [dns nameserver entries](./modules/hosts/dns/default.nix) .

### Networking

Every setup is part of a ~~tail~~*head*scale vpn to facilitate communication between setups.

DNS is set up with [Unbound](https://www.nlnetlabs.nl/projects/unbound/about/) and routes requests to serves which then reverse proxy them to the respective services using [Caddy](https://caddyserver.com/).

## Deployment & Secrets

Deployment is handled by serokell's fantastic [deploy-rs](https://github.com/serokell/deploy-rs).
Secrets are provisioned via [sops-nix](https://github.com/Mic92/sops-nix) using [age](https://github.com/FiloSottile/age)-keys.

## Monitoring

I have implemented a basic ~~[vector.dev](https://vector.dev/)~~ [Promtail](https://grafana.com/docs/loki/latest/clients/promtail/) configuration to send the system's syslog to [Grafana](https://grafana.com/) and pull system stats to [Prometheus](https://prometheus.io/).
