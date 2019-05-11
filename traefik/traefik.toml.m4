#[global]
#debug = true
#[log]
#level = "debug"

[api]
dashboard = true

[entryPoints]
  [entryPoints.web]
  address = ":80"
#    [entryPoints.http.redirect]
#    entryPoint = "https"

  [entryPoints.web-secure]
  address = ":443"
#    [entryPoints.https.tls]
#      [entryPoints.https.tls.ClientCA]
#      files = ["/etc/ssl/auth-ca/ca-chain.cert.pem"]
#      optional = false
ifelse(ENV, development,
#      [[entryPoints.https.tls.certificates]]
#      certFile = "/etc/ssl/auth-ca/star.DOMAIN.full.pem"
#      keyFile = "/etc/ssl/auth-ca/star.DOMAIN.key.pem"
)

#[retry]

[providers.docker]
#domain = "DOMAIN"
exposedByDefault = false
changequote(<<, >>)
defaultRule = """
Host(`{{ \
  regexReplaceAll "-[^-]*$" (normalize .Name) "" \
}}.DOMAIN`)"""
changequote(`, ')

ifelse(ENV, production,
#[acme]
#  email = "OWNER_EMAIL"
#  storage = "/acme/certs.json"
#  entrypoint = "https"
#  [acme.dnsChallenge]
#    provider = "cloudflare"
#  [[acme.domains]]
#    main = "*.DOMAIN"
#    sans = ["DOMAIN"]
)
