SERVICES=traefik whoami

up: $(SERVICES)

down:
	for i in $(SERVICES); do cd $$i; docker-compose down; cd ..; done

traefik: traefik/traefik.toml traefik/auth-ca
	cd $@; docker-compose up -d

traefik/traefik.toml: traefik/traefik.toml.m4
	m4 -D ENV=$(ENV) \
		-D DOMAIN=$(DOMAIN) \
		-D OWNER_EMAIL=$(OWNER_EMAIL) \
		$^ >$@

traefik/auth-ca:
	mkdir $@
ifeq ($(ENV),development)
	cp $(IMAGE_DATA)/ca/intermediate/dist/star.h.$(DOMAIN).full.pem $@
	cp $(IMAGE_DATA)/ca/intermediate/private/star.h.$(DOMAIN).key.pem $@
endif

whoami:
	cd $@; docker-compose up -d

bootstrap: bootstrap-docker bootstrap-ca

bootstrap-docker:
	docker network create web

bootstrap-ca:
	cd ca; ./create-root.sh
	cd ca; ./create-intermediate.sh
	cd ca; ./create-certificate.sh --server \
		*.h.$(DOMAIN),h.$(DOMAIN)

.PHONY: bootstrap up down $(SERVICES)
