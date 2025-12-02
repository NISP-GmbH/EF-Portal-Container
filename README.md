# EnginFrame Portal

Welcome to our EF Portal container solution!

This is the easiest way to start EF Portal just providing the license file.

# How to start

1. Download the `docker-compose.yml` file
2. Save your EF Portal license with the name `license.ef` in the same directory
3. Edit the `docker-compose.yml` and set a new powerful password in the variable `EFP_ADMIN_PASSWORD`
3. Execute:
```bash
docker compose up -d
```
4. Open the `https://yourip_or_domain/` and do the login with `efadmin` user and the new password or efadmin33 default password

__Tips:__
- You can open https://yourip_or_domain/start page to get useful EF Portal information
- If you get the Nginx 502 message, EF Portal is still starting or you did not provide valid license.ef

# Architecture

- Nginx (1.24.0) service to proxy 80/443(ssl) access to EF Portal using AJP Connector
- EF Portal latest version (or specific version using docker tags)
- DCV Session Manager Broker (latest version)
- DCV Session Manager CLI (latest version)
- SLURM 24.05.2 using Munge

# Requirements

## Hardware
- 4 CPU
- 8GB memory
- 20GB storage

## Software
- Docker service installed
- RedHat/CentOS/Rocky/Alma Linux 8/9
- Debian 9+ /Ubuntu 22+ Linux

__Tips:__
- Inside of tools/ you cand find the scripts to setup docker
- Podman can be used
