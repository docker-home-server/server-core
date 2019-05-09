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
	cp $(IMAGE_DATA)/ca/intermediate/certs/ca-chain.cert.pem $@
ifeq ($(ENV),development)
	cp $(IMAGE_DATA)/ca/intermediate/dist/star.$(DOMAIN).full.pem $@
	cp $(IMAGE_DATA)/ca/intermediate/private/star.$(DOMAIN).key.pem $@
endif

whoami:
	cd $@; docker-compose up -d

bootstrap: bootstrap-docker bootstrap-ca

bootstrap-docker:
	docker network create web

bootstrap-ca:
	cd ca; ./create-root.sh
	cd ca; ./create-intermediate.sh
	cd ca; ./create-certificate.sh --server *.$(DOMAIN),$(DOMAIN)

clean:
	rm -f traefik/traefik.toml
	rm -rf traefik/auth-ca

.PHONY: bootstrap up down clean $(SERVICES)
