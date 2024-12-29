# homeserver-docker

This is my current private homeserver setup, deployed with docker compose on a Linux server. 
I decided to share this project as an example for a simple reverse proxy setup with TLS (self-signed certificates) in a local home network.

## Prerequisites

- Docker with docker compose


## Quick Start

Traefik is thi single required service in this setup. You need to either follow the existing configuration or change it to match your desired results.

1. Generate your self-signed certificates (with your own CA or otherwise) and store the **domain** certificate and key in `traefik/certs/` *or* disable SSL (entrypoint web) and TLS (tls=false) in Traefik for each service.
2. Each service has its own environment variables defined in a `.env` file in the same directory as the `docker-compose.yml`. These may create secrets so you need to create these yourself, tailored to your configuration.

    > :warning: Take special note of the Traefik and Homepage configuration files!

3. Tailor the configurations and docker-compose files to your needs.
4. Start your services separately with the command `docker compose up -d` or, use either `./restart.sh` or `./restart.ps1`.
5. With the default configuration, the server is now running on https://homeserver.internal. Each service runs on thr host `containerName.homeserver.internal`.


## Service-specific Configuration

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

- Permission denied error on config files (local or ``/var/docker``) 

    :arrow_forward: Check if your user has write permissions.
