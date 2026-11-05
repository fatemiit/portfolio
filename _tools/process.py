import os, re, sys
from urllib.parse import urljoin, urlparse
SITE = sys.argv[1]
DOMAIN = sys.argv[2] if len(sys.argv) > 2 else None
for root, _, files in os.walk(SITE):
    for f in files:
        if not f.endswith(".html"): continue
        fp = os.path.join(root, f)
        rel = os.path.relpath(fp, SITE)
        page = "" if rel == "index.html" else (rel[:-len("/index.html")] if rel.endswith("/index.html") else rel[:-5])
        base = "https://x.test/" + page
        html = open(fp, encoding="utf-8").read()
        def fix(m):
            v = m.group(2)
            u = urlparse(urljoin(base, v))
            p = u.path or "/"
            return m.group(1) + p + (("#" + u.fragment) if u.fragment else "") + '"'
        html = re.sub(r'(href=")(\.{1,2}/[^"]*)"', fix, html)
        html = re.sub(r'<link[^>]*framer\.com/edit/init\.mjs[^>]*>', '', html)
        html = re.sub(r'<script[^>]*events\.framer\.com[^>]*>\s*</script>', '', html)
        html = html.replace("</head>", "<style>#__framer-badge-container{display:none!important}</style></head>", 1)
        if DOMAIN:
            html = html.replace("https://fatemiit.framer.website", "https://" + DOMAIN)
        open(fp, "w", encoding="utf-8").write(html)
        print("ok", rel)
