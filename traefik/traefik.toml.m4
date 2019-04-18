[web]
address = ":8080"

[entryPoints]
  [entryPoints.http]
  address = ":80"
#    [entryPoints.http.redirect]
#    entryPoint = "https"

#  [entryPoints.https]
#  address = ":443"
#    [entryPoints.https.tls]

[retry]

[docker]
domain = "h.DOMAIN"
exposedByDefault = false
