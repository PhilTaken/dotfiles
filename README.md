# My NixOS dotfiles

> Always remember that you are absolutely unique. Just like everyone else.
>
> --- Margaret Mead

## Introduction / Foreword

These dotfiles, as they are laid out here, are the culmination of over two years of work, tinkering and experimentation.  
Going back and forth, trying out different strategies, failing and succeeding.

This current state, too, is just a snapshot in time - the still picture of a colibri flapping it's wings, a snowflake, frozen in time.  
Stateless and stateful all at once.

Observe, for this is my canvas.

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
This file also serves as means to generate DNS entries for [Unbound](./modules/hosts/server/unbound.nix), reverse proxy entries for [Caddy](./modules/hosts/server/caddy/default.nix), a basic ip lookup table for [nfs mounts](./modules/hosts/fileshare/default.nix), [dns nameserver entries](./modules/hosts/dns/default.nix) as well as the [wireguard](./modules/hosts/wireguard/default.nix) and [nebula](./modules/hosts/nebula/default.nix) config modules.

### Networking

Every setup is part of a [wireguard](https://www.wireguard.com/) and a [nebula](https://github.com/slackhq/nebula) vpn / network overlay to facilitate communication between setups.

DNS is set up with [Unbound](https://www.nlnetlabs.nl/projects/unbound/about/) and routes requests to serves which then reverse proxy them to the respective services using [Caddy](https://caddyserver.com/).

## Deployment & Secrets

Deployment is handled by serokell's fantastic [deploy-rs](https://github.com/serokell/deploy-rs).
Secrets are provisioned by [sops-nix](https://github.com/Mic92/sops-nix) using [age](https://github.com/FiloSottile/age)-keys.

## Monitoring

**early WIP**

I have implemented some basic [telegraf](https://www.influxdata.com/time-series-platform/telegraf/) to [influxdb2](https://www.influxdata.com/) monitoring for basic metrics such as temperature and cpu utilisation as well as [vector](https://vector.dev/) to send the system's syslog to [grafana](https://grafana.com/).
