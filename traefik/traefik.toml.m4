changequote(<<, >>)dnl
[log]
  level = "debug"

[entryPoints]
  [entryPoints.http]
    address = ":80"
  [entryPoints.https]
    address = ":443"
ifelse(ACME, yes,
    [entryPoints.https.http.tls]
      certResolver = "wildcard"
      [[entryPoints.https.http.tls.domains]]
        main = "*.DOMAIN"
        sans = ["DOMAIN"]

[certificatesResolvers.wildcard.acme]
  email = "OWNER_EMAIL"
  storage = "/acme/certs.json"
  [certificatesResolvers.wildcard.acme.dnsChallenge]
    provider = "cloudflare"
)dnl

[providers]
  [providers.file]
    directory = "/conf"
  [providers.docker]
    exposedByDefault = false
    defaultRule = """
      Host(`{{ \
        regexReplaceAll "-[^-]*$" (normalize .Name) "" \
      }}.DOMAIN`)"""

[api]
  dashboard = true
