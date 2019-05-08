defaultEntryPoints = ["http", "https"]

# debug = true
# [accessLog]

[web]
address = ":8080"

[entryPoints]
  [entryPoints.http]
  address = ":80"
    [entryPoints.http.redirect]
    entryPoint = "https"

  [entryPoints.https]
  address = ":443"
    [entryPoints.https.tls]
ifelse(ENV, development,
      [[entryPoints.https.tls.certificates]]
      certFile = "/etc/ssl/auth-ca/star.h.DOMAIN.full.pem"
      keyFile = "/etc/ssl/auth-ca/star.h.DOMAIN.key.pem"
)

[retry]

[docker]
domain = "h.DOMAIN"
exposedByDefault = false

ifelse(ENV, production,
[acme]
  email = "OWNER_EMAIL"
  storage = "/acme/certs.json"
  entrypoint = "https"
  [acme.dnsChallenge]
    provider = "cloudflare"
  [[acme.domains]]
    main = "*.h.DOMAIN"
    sans = ["h.DOMAIN"]
)
