traefik: traefik/traefik.toml
	cd $@; docker-compose up -d

traefik/traefik.toml: traefik/traefik.toml.m4
	m4 -D DOMAIN=$(DOMAIN) $^ >$@

.PHONY: bootstrap
bootstrap:
	docker network create web
