# HeartStrings Website

Static site for UC Berkeley's HeartStrings club. No build step and no
dependencies — plain HTML/CSS served as files by the OCF.

## Layout

- `site/` — everything the public sees; its contents become the web root
  - `index.html`, `executive-team.html`, `get-involved.html`, `photos.html`
  - `styles.css` — all styling, shared by every page
  - `assets/` — logo, QR codes, `photos/<event>/`, `team/` headshots
  - `.htaccess`
- `deploy/post-receive` — source of truth for the server-side deploy hook
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

## Git: no Claude attribution, ever

Commits and pull requests from this repo must never indicate that they were
written or co-written by Claude. Never add:

- a `Co-Authored-By` trailer naming Claude
- a "Generated with Claude Code" line, or the robot footer in a PR body
- `noreply@anthropic.com` as an author or co-author

Write commit messages as the human author, with no attribution trailer of any
kind.

This is also enforced mechanically, in two independent places, so it holds even
if this file is not read:

1. `attribution: {commit: "", pr: ""}` in `~/.claude/settings.json` — stops
   Claude Code from appending the trailers on its own.
2. `~/.claude/hooks/block-claude-attribution.sh`, wired as a `PreToolUse` hook
   on `Bash` — denies any command that both invokes `git commit` / `gh pr
   create` and carries an attribution marker.

Both live in user-global settings, so they apply to every repo on this machine,
not just this one.
