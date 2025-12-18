# homeserver-docker

This is my current private homeserver setup, deployed with docker compose on a Linux server. 
I decided to share this project as an example for a simple reverse proxy setup with TLS (self-signed certificates) in a local home network.
This repository is mainly intended to present a baseline for your own homeserver stack.
Nevertheless, if you are using my stack then a fair warning: **I may break or migrate my setup frequently**.
If you want use this stack directly, i recommend forking it instead of using my main branch directly. 


![Homeserver-Dashboard](https://github.com/user-attachments/assets/bd093db8-78b9-4c46-a1b4-028b733e4865)


## Prerequisites

- Docker with docker compose
- Docker knowledge
- Some Linux proficiency, or looking it  up

## Manage the Docker Stacks
`homeserver.sh` is a little script to manage the docker stacks.
Starting stacks, stopping them, updating currently running stacks, backups...

## Quick Start

Traefik is the single required service in this setup. You need to either follow the existing configuration or change it to match your desired results.

1. Generate your self-signed certificates (with your own CA or otherwise) and store the **domain** certificate and key in `traefik/certs/` *or* disable SSL (entrypoint web) and TLS (tls=false) in Traefik for each service.
2. Each service has its own environment variables defined in a `.env` file in the same directory as the `docker-compose.yml`. These may create secrets so you need to tailor these (use `.env.example` files for var declarations) files to your specific configuration.

    > :warning: Take special note of the Traefik and Homepage configuration files!

3. Tailor the configurations and docker-compose files to your needs.
4. Start your services separately with the command `docker compose up -d` or, use either `./homeserver.sh` or `./homeserver.ps1` (not really well maintained).
    > :warning: Some applications may setup their startup configuration as *root*. It might be required to manually set ownership of these files to your user after the first service start in the config dir (default */var/docker/applicationName*).
5. With the default configuration, the server is now running on https://homeserver.internal. Each service runs on `containerName.homeserver.internal`.


## Service-specific Configuration

### ArchiSteamFarm (ASF)

To be able to actually connect to ASF-ui, we need to configure ASF's IPC not to listen only on localhost. In addition to the pre-configured `docker-compose.yml`, create a file named `IPC.config` with the following content (taken from the [official ASF wiki](https://github.com/JustArchiNET/ArchiSteamFarm/wiki/IPC#custom-configuratio)) and put in in your ASF config dir (/var/docker/archisteamfarm/config):

```json
{
	"Kestrel": {
		"Endpoints": {
			"http4": {
				"Url": "http://*:1242"
			}
		},
		"KnownNetworks": [
			"10.0.0.0/8",
			"172.16.0.0/12",
			"192.168.0.0/16"
		],
		"PathBase": "/"
	}
}
```
As ASF is practically running in headless mode (on a server without user interaction), you may need to input a Steam Guard Code during the login: 
```md
input <BotName> TwoFactorAuthentication <SteamGuardCode>
```

### Jellyfin
Since version 10.10.7 you **have** to configure known proxies under `Networking`, otherwise you cannot connect to Jellfin via the configured Traefik host.
You can find the IP adress of Traefik per `docker inspect traefik` and then paste the address from *NetworkSettings.Networks.IPAddress* to 'known proxies' in the Jellyfin networking configuration.
It is also possible to use CIDR notation, for example `127.0.0.1/24, 172.18.0.1/24`.

> :warning: Make sure that '*Allow remote connections to this server*' under 'Remote Access Settings' is disabled.


### Traefik
The static confiuration `config/traefik.yml` contains a default host rule if none is defined by the service. You can change or delete this configuration as you like.

```yaml
providers:
  docker:
    defaultRule: Host(`{{ normalize .ContainerName }}.homeserver.internal`)
```


### Uptime-Kuma
When setting up a Docker host, you have to link to the docker proxy container.

`Connection Type: TCP/HTTP`  
`Docker Deamon: tcp://dockerproxy_kuma:2375`


## FAQ

- Why `.internal`?

    :arrow_forward: Because of [this proposal](https://www.icann.org/en/public-comment/proceeding/proposed-top-level-domain-string-for-private-use-24-01-2024).


## Troubleshooting

- Permission denied error on config files (local or `/var/docker`) 

    :arrow_forward: Check if your user has write permissions.
