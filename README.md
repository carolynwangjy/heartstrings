# heartstrings

uc berkeley's music service and wellness club :)

The live site is served by the [OCF](https://www.ocf.berkeley.edu/) out of the
`heartstrings` account's `~/public_html`.

## Layout

Everything the public sees lives in `site/` — that directory's contents become
the web root. Everything else (this README, `deploy/`) stays in git and is
never published.

## Deploying

`git push` **is** the deploy. `origin` has two push URLs — GitHub (history) and
the OCF server (the live site) — so one push updates both:

```bash
git pull            # get everyone else's changes first
# ...edit...
git add -A && git commit -m "..."
git push            # -> GitHub, and live within a second or two
```

Only `main` deploys; pushing any other branch updates GitHub alone.

## One-time setup

Each person needs SSH access to the shared `heartstrings` OCF account, then:

```bash
git clone git@github.com:carolynwangjy/heartstrings.git
cd heartstrings
git remote set-url --add --push origin git@github.com:carolynwangjy/heartstrings.git
git remote set-url --add --push origin heartstrings@ssh.ocf.berkeley.edu:site.git
git remote -v        # push should list both URLs
```

Both lines are needed: adding any push URL replaces the default one, so the
GitHub URL has to be re-stated explicitly.

## Server setup (done once, for the whole club)

From a clone, with SSH access to the shared `heartstrings` OCF account:

```bash
ssh heartstrings@ssh.ocf.berkeley.edu 'sh -s' < deploy/setup-server.sh
```

That creates the bare repo and installs the deploy hook. It is safe to re-run —
re-running reinstalls the hook, which is how you ship a change to
[deploy/setup-server.sh](deploy/setup-server.sh) itself. It also snapshots the
current live site to `~/public_html.bak` the first time.
