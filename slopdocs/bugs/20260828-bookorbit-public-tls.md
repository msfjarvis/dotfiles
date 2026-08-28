# BookOrbit public hostname returned Cloudflare 525

- Public `curl https://books.msfjarvis.dev` returned Cloudflare 525. Directly probing Melody's Caddy listener with `books.msfjarvis.dev` as SNI returned a TLS internal-error alert, reproducing the failed Cloudflare-to-origin handshake without involving BookOrbit.
- The application URL and proxy site were configured separately, so setting the now-removed `services.jarvis.bookorbit.appUrl` option did not create a Caddy site for the public hostname.
- Melody's Caddy storage still contained its existing `books.msfjarvis.dev` certificate. The failure was missing active site configuration, not certificate issuance or the BookOrbit/PostgreSQL startup failure.

## Corrected design

BookOrbit now requires a fully-qualified public `domain`. Its NixOS module uses `https://${domain}` for `APP_URL` and owns the matching Caddy virtual host, including the repository reaction log format, gzip/zstd encoding, and reverse proxy to the module's loopback-only HTTP port. There is no separate `appUrl` option that can drift from the served hostname. Melody sets `domain = "books.msfjarvis.dev"`; no separate Caddy site is needed there.
