#!/usr/bin/env bash
# Re-export the live Framer site into this repo. Run from repo root: bash _tools/sync.sh
set -euo pipefail
SRC=https://fatemiit.framer.website
DOMAIN=mohammadfatemi.com
ROOT=$(pwd)
TMP=$(mktemp -d)
curl -sS "$SRC/sitemap.xml" -o "$TMP/sitemap.xml"
grep -o '<loc>[^<]*' "$TMP/sitemap.xml" | sed 's#<loc>##' | while read -r url; do
  p=${url#"$SRC"}; p=${p#/}
  mkdir -p "$TMP/site/$p"
  for i in 1 2 3; do
    curl -sS "$url" -o "$TMP/site/$p/index.html"
    [ "$(stat -c%s "$TMP/site/$p/index.html")" -gt 60000 ] && break
    sleep 3
  done
  echo "fetched /$p ($(stat -c%s "$TMP/site/$p/index.html") bytes)"
done
python3 -I "$ROOT/_tools/process.py" "$TMP/site" "$DOMAIN" >/dev/null
sed "s#$SRC#https://$DOMAIN#g" "$TMP/sitemap.xml" > "$TMP/site/sitemap.xml"
printf 'User-agent: *\nAllow: /\nSitemap: https://%s/sitemap.xml\n' "$DOMAIN" > "$TMP/site/robots.txt"
# replace old pages, keep repo-only files
find "$ROOT" -mindepth 1 -maxdepth 1 ! -name .git ! -name _tools ! -name CNAME ! -name .nojekyll ! -name 404.html -exec rm -rf {} +
cp -r "$TMP/site/." "$ROOT/"
rm -rf "$TMP"
echo done
