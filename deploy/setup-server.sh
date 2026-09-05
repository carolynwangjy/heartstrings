#!/bin/sh
# One-time server setup for push-to-deploy. Safe to re-run; re-running
# reinstalls the hook with whatever this file currently says.
#
# From a clone of this repo, run:
#   ssh heartstrings@ssh.ocf.berkeley.edu 'sh -s' < deploy/setup-server.sh

set -e

BARE="$HOME/site.git"
PUBLISH="$HOME/public_html"

command -v git   >/dev/null 2>&1 || { echo "!! git not found on this server";   exit 1; }
command -v rsync >/dev/null 2>&1 || { echo "!! rsync not found on this server"; exit 1; }

# Snapshot whatever is currently live, once, before anything can clobber it.
if [ -d "$PUBLISH" ] && [ ! -d "$HOME/public_html.bak" ]; then
  cp -r "$PUBLISH" "$HOME/public_html.bak"
  echo "==> backed up current site to ~/public_html.bak"
fi

mkdir -p "$PUBLISH"
[ -d "$BARE" ] || { git init --bare "$BARE" >/dev/null; echo "==> created $BARE"; }

cat > "$BARE/hooks/post-receive" <<'HOOK'
#!/bin/sh
# Publishes the repo's site/ directory into public_html on every push to main.
set -e

GIT_DIR_ABS="$HOME/site.git"
STAGING="$HOME/.deploy-staging"   # full checkout, kept between deploys
PUBLISH_DIR="$HOME/public_html"   # what the world sees
SUBDIR="site"
BRANCH="main"

# The web server has to be able to read whatever we write.
umask 022

while read -r oldrev newrev ref; do
  if [ "$ref" != "refs/heads/$BRANCH" ]; then
    echo "==> ignoring $ref (only $BRANCH deploys)"
    continue
  fi

  echo "==> deploying $(echo "$newrev" | cut -c1-7)"

  # Check the commit out somewhere private. Reusing the same directory keeps
  # this incremental instead of rewriting every image on every deploy.
  mkdir -p "$STAGING"
  git --git-dir="$GIT_DIR_ABS" --work-tree="$STAGING" checkout -f "$BRANCH"
  git --git-dir="$GIT_DIR_ABS" --work-tree="$STAGING" clean -fd

  # --delete makes removals and renames actually take effect, instead of the
  # old file lingering on the server forever.
  rsync -a --delete "$STAGING/$SUBDIR/" "$PUBLISH_DIR/"

  echo "==> done"
done
HOOK

chmod +x "$BARE/hooks/post-receive"
echo "==> hook installed; server ready to receive pushes"
