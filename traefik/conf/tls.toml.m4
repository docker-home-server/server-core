changequote(<<, >>)dnl
ifelse(ACME, no,
[[tls.certificates]]
  certFile = "/etc/ssl/auth-ca/star.DOMAIN.full.pem"
  keyFile = "/etc/ssl/auth-ca/star.DOMAIN.key.pem"
)dnl

[tls.options]
  [tls.options.default]
    [tls.options.default.clientAuth]
      caFiles = ["/etc/ssl/auth-ca/ca-chain.cert.pem"]
      clientAuthType = "RequireAndVerifyClientCert"

[http.middlewares]
  [http.middlewares.https-redirect.redirectscheme]
    scheme = "https"
    permanent = true
ifelse(ENV, development,
<<    >>port = HTTPS_PORT
)dnl
