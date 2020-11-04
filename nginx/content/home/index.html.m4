<!DOCTYPE html>
<html lang="en" dir="ltr">
  <head>
    <meta charset="utf-8">
    <title>DOMAIN</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style media="screen">
      body {
        margin: 0;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      }

      header {
        width: 100%;
        height: 2em;
        line-height: 2em;
        text-align: center;
        font-style: bold;
        border-bottom: 1px solid black;
      }

      main {
        margin: 0.5em;
      }

      .buttons {
        padding: 0;
      }

      .buttons li {
        width: 100%;
        display: block;
      }

      .buttons li a {
        display: block;
        max-width: 30em;
        height: 2em;
        line-height: 2em;
        text-align: center;
        border: 1px solid;
        border-radius: 8px;
        margin-bottom: 0.5em;
      }

      @media only screen and (min-width: 35em) {
        .buttons li {
        }
      }
    </style>
  </head>
  <body>
    <header>
      Welcome home!
    </header>

    <main>
      <h2>Applications</h2>
      <ul class="buttons">
        include(`applications.html')
      </ul>

      <h2>Housekeeping</h2>
      <ul class="buttons">
ifelse(HTTPS_PORT, 443,
        <li><a href="https://whoami.DOMAIN/">whoami</a></li>
        <li><a href="https://traefik.DOMAIN/dashboard/">traefik dashboard</a></li>,
        <li><a href="https://whoami.DOMAIN:HTTPS_PORT/">whoami</a></li>
        <li><a href="https://traefik.DOMAIN:HTTPS_PORT/dashboard/">traefik dashboard</a></li>
)dnl
      </ul>
    </main>
  </body>
</html>
