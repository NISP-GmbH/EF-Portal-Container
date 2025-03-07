# EnginFrame Portal

Welcome to our EF Portal container solution!

- Do you want to easily test EF Portal?
- And how about load EF Portal with your SSSD service just providing the sssd.conf?
- Do you want to run EF Portal in the same host of your current old EF solution without conflict?
- Do you want to easily load SLURM from the host inside of the EF Portal container?

If you said at least one yes, you are in the right place!

With a very short, explained and descomplicated wizard you will generate your __docker-compose.yml__ and __.env__ files to easily startup the container that will support your requirements.

And if you just need to start EP Portal without answer anything, the wizard will offer that option to you.

If you have any questions, please open a git issue or send an e-mail to efpsupport@ni-sp.com. And if you do not have a license demo, you can ask in the same e-mail.

# How to start the wizard?

## Requirements

Is very simple, but first you need to setup docker in your server. If you need some help, we did some scripts to help you. Check them inside of "tools/" directory.

You can setup docker in any Ubuntu server version and all RedHat based linux distros (EL8 and EL9), like CentOS, AlmaLinux, Rocky Linux etc.

Note: As CentOS 6 and 7 reached the EOL, we do not recommend to use our solution there. Just to you know, if you really needed to use and you know what you are doing, EF Portal will work fine!

Take a good bottle of water, setup docker and continue to the next step. ;)

## EF Portal

Now that you have docker installed with docker compose plugin, you are about one minute to have EF Portal!

Execute our script, read the recommendations and in the end you will have EP Portal running under container. Easy easy! 

```bash
bash wizard.sh
```

Congratulations! Now you are ready to start EP Portal under container and access the web dashboard!

Ah, and do not forget to hydrate! ;)

# What are the advantages about running EF Portal in a docker?
* Will be isolated from your Host OS, so you can run even inside of your current old EF instance without cause any issues.
* You can easily update EF Portal just stopping the instance, doing a docker image pull and starting EF Portal again.
* You can customize bash scripts inside of EF Portal and never lose them after updates; And all customized files will be documented under docker-compose.yml file, so you will never forget about what was done some years ago.
* You can move EF Portal to a very old operating systems (if you really need) or very unusual linux distributions; They just need to support docker.
* You can limit the hardware resources (CPU, Memory etc) to EF Portal.

## Frequent Asked Questions
* __How can I access the EF Portal?__
Go to https://YOURIP:PORT and use the port, user and password that were configured in the .env file. The IP can be localhost or your external valid IP.

* __"Access Failure: User not authorized. Contact EF Portal Administrator."__
You forgot to add your license.ef in the same directory of docker-compose.yml file. If you do not have one, please ask your demo license for efpsupport@ni-sp.com.

* __How to boot the container?__
```bash
# execute in the same directory of docker-compose.yml
docker compose up -d
```

* __How to stop the container?__
```bash
# execute in the same directory of docker-compose.yml
docker compose down
```

* __How to remove the container?__

```bash
docker rm container-id
```

* __How to get container id?__

First execute
```bash
docker ps -a
```

which will show the running container similar to: 

```bash
9fac0c022faf   nispgmbh/ef-dcv-container:efportal   "/bin/bash /opt/cont…"   11 seconds ago   Up 10 seconds   8553/tcp, 0.0.0.0:8553->8443/tcp, :::8553->8443/tcp   efportal-nisp
```

The container id is the first column.


* __How to enter in container command line?__

```bash
docker exec -it container-id  /bin/bash
```

* __How to show container logs?__
```bash
docker logs container-id
```

* __Is it possible to change any answer that I did during the wizard?__
We always recommend to run the wizard again, so the script can validate all answers. But if you know what you are doing, you can edit the .env file.

* __I did not find the .env file!__
The .env file is a hidden file. You can see with the command "ls -la", using terminal, or configuring your GUI file explorer to show hidden files. You can use any text editor to change the file.

* __How to EF Portal load SLURM and Munge binaries from the server?__
Yes. Edit the .env and set SLURM_SERVICE_ENABLED=true and then check if you need to change other SLURM variables. **Important:** You need to have same glibc version in the host, or is possible that those binaries can not run correctly inside of the container.

* __Can I customize the docker-compose.yml file?__
We do not recommend that unless you really know what you are doing!

* __Can I use Podman instead of Docker?__
Is not officially supported by us, but we always try to maintain our docker-compose.yml and .env files compatible with Podman.

* __Why the wizard ask to mount external directories (sessions/spoolers)?__
Because in big  environments those directories can quickly grow the size, so we must guarantee that you will offer enough space to them, avoiding fill all the space of the host where the docker is running.
