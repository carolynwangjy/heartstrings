# Heartstrings

Welcome to the website page of UC Berkeley's music service and wellness club :)

The live site is [www.ocf.berkeley.edu/~heartstrings](https://www.ocf.berkeley.edu/~heartstrings/),
hosted by the [OCF](https://www.ocf.berkeley.edu/).

## How deploying works

**`git push` publishes the site.** There's no separate upload step.

```
  edit site/  →  git commit  →  git push  ─┬─→  GitHub              history + backup
                                           │
                                           └─→  OCF  ~/site.git     a bare repo that
                                                       │            just receives pushes
                                                       │
                                                       │  a "post-receive" hook
                                                       │  fires automatically
                                                       ▼
                                                   ~/public_html    the live site
```

`origin` is configured with two push URLs, so one `git push` sends your commits
to both places. GitHub just stores them. The OCF side stores them *and* runs a
hook that copies everything in `site/` into `public_html`, which is the folder
the OCF web server serves to the public.

The whole thing takes a second or two. You'll see the hook report back in your
terminal:

```
remote: ==> deploying 332bd11
remote: ==> done
```

Only `main` deploys. Pushing any other branch goes to GitHub alone and leaves
the live site untouched — useful for work in progress.

## Making a change

This is the only section most people need, day to day.

```bash
git pull                        # get everyone else's changes first
# ...edit files in site/...
git add -A
git commit -m "what you changed"
git push                        # live within a couple of seconds
```

Then load the site and check it looks right.

## Setting up your laptop

Once per person, per computer. You need SSH access to the shared `heartstrings`
OCF account — ask a club officer, or reset the password at
[ocf.io/password](https://ocf.io/password) if you're a signatory.

```bash
git clone git@github.com:carolynwangjy/heartstrings.git
cd heartstrings

# Send pushes to GitHub *and* the OCF server.
git remote set-url --add --push origin git@github.com:carolynwangjy/heartstrings.git
git remote set-url --add --push origin heartstrings@ssh.ocf.berkeley.edu:site.git

# So pushing doesn't ask for the shared password every time.
ssh-copy-id heartstrings@ssh.ocf.berkeley.edu

git remote -v                   # check: "push" should list both URLs
```

Both `set-url` lines are needed. Adding any push URL replaces the default one,
so GitHub's has to be restated explicitly — otherwise you'd push to OCF only.

## Setting up the server

**Already done. You don't need to run this.** It's here in case the account is
ever rebuilt, or the deploy hook needs to change.

```bash
ssh heartstrings@ssh.ocf.berkeley.edu 'sh -s' < deploy/setup-server.sh
```

That creates the bare repo at `~/site.git` and installs the hook. It's safe to
re-run — re-running reinstalls the hook, which is how you ship an edit to
[deploy/setup-server.sh](deploy/setup-server.sh). The first run also snapshots
the pre-existing site to `~/public_html.bak`.

## What's in here

- **`site/`** — everything the public sees. Its contents become the web root, so
  `site/index.html` is the homepage.
  - `styles.css` — all styling, shared by every page
  - `assets/` — logo, QR codes, `photos/<event>/`, `team/` headshots
  - `.htaccess` — cache headers, so pages don't go stale after a deploy
- **`deploy/`** — the server setup script. Stays in git, never published.
- `README.md`, `CLAUDE.md` — same: in git, never published.

Asset paths are relative (`assets/team/foo.jpg`), so pages and `assets/` have to
stay siblings inside `site/`.

To preview before pushing: `cd site && python3 -m http.server 8934`, then open
<http://localhost:8934>.

## Things to know

**Don't use `scp` anymore.** The old instructions were:

```bash
scp -r ~/Desktop/Heartstrings/club-website/* heartstrings@ssh.ocf.berkeley.edu:~/public_html/
```

That no longer works safely. `public_html` is now managed by the deploy hook,
which mirrors `site/` into it and **deletes anything that isn't in the repo**.
Files uploaded by `scp` exist in no commit, so the next person's `git push`
silently erases them.

**If it isn't committed, it isn't on the site.** Deploys publish commits, not
whatever happens to be in your folder. `git status` will tell you what you've
missed.

**Deletions and renames work now.** Deleting a file from `site/` removes it from
the server on the next push. Under `scp`, old files lingered forever.

**If `git push` asks for a password,** you skipped `ssh-copy-id` above.
