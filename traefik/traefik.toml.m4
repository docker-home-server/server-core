# debug = true
# [accessLog]

defaultEntryPoints = ["http", "https"]

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
