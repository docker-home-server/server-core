changequote(<<, >>)dnl
[http]
  [http.routers]
    [http.routers.dashboard]
      rule = "Host(`traefik.DOMAIN`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
      service = "api@internal"
      [http.routers.dashboard.tls]
