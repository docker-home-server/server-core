SERVICES=traefik whoami

up: $(SERVICES)

down:
	for i in $(SERVICES); do cd $$i; docker-compose down; cd ..; done

traefik: traefik/traefik.toml
	cd $@; docker-compose up -d

traefik/traefik.toml: traefik/traefik.toml.m4
	m4 -D ENV=$(ENV) \
		-D DOMAIN=$(DOMAIN) \
		-D OWNER_EMAIL=$(OWNER_EMAIL) \
		$^ >$@

whoami:
	cd $@; docker-compose up -d

bootstrap:
	docker network create web

.PHONY: bootstrap up down $(SERVICES)
