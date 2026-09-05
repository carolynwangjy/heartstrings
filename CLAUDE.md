# HeartStrings Website

Static site for UC Berkeley's HeartStrings club. No build step and no
dependencies — plain HTML/CSS served as files by the OCF.

## Layout

- `site/` — everything the public sees; its contents become the web root
  - `index.html`, `executive-team.html`, `get-involved.html`, `photos.html`
  - `styles.css` — all styling, shared by every page
  - `assets/` — logo, QR codes, `photos/<event>/`, `team/` headshots
  - `.htaccess`
- `deploy/setup-server.sh` — one-time server setup; contains the deploy hook
- `README.md`, `CLAUDE.md` — stay in git, never published

Asset paths are relative to `site/` (e.g. `assets/team/foo.jpg`), so pages and
`assets/` must stay siblings inside `site/`.

To preview locally: `cd site && python3 -m http.server 8934`, then open
http://localhost:8934.

## Deploying

`git push` is the deploy — `origin` has two push URLs (GitHub for history, the
OCF server for the live site). Only `main` deploys. See README.md for the full
workflow and one-time setup.

Because a push to `main` goes straight to the live site, treat `main` as
production: check pages render before pushing.