# EnginFrame Portal

## Basic configuration

**Note:** Do not edit docker-compose.yml unless you know what you are doing. You have to only edit .env file.

Please set where is the current EF Portal license:

```bash
EFP_LICENSE_FILE=./conf/license.ef
```

Usually you just need to change the FQDN domain to access the EF PORTAL and set a port that is not being used in your host. If you do not have a domain, you can leave the variable with default config and access using Host IP.

```bash 
EFP_FQDN_DOMAIN=mydevsubdomain.mydomain.com
EFP_PORT=8553
```
If you have different Slurm or munge key path configuration, you also need to configure:

```bash
SLURM_SERVICE_ENABLED=false
SLURM_BIN_DIR=/usr/bin
SLURM_CONF_DIR=/etc/slurm
SLURM_MUNGE_KEY=/etc/munge/munge.key
SLURM_MUNGE_SOCKET_DIR=/var/run/munge
```

If you also want to run SSSD service with your sssd.conf file, please replace "false" with "true" and check the correct sssd.conf path.

```bash
SSSD_SERVICE_ENABLED=false
SSSD_CONF_FILE=/etc/sssd/sssd.conf
```

## How to run

```bash
docker compose up -d
```

## How to stop

```bash
docker compose down
```
