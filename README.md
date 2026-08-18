# Portfolio CMS

Admin UI for my portfolio content. The content itself lives in this repo as JSON and is the
source of truth — the portfolio fetches it straight from GitHub.

```
./dev.sh  →  Decap admin on localhost  →  writes content/*.json  →  git push  →  GitHub
                                                                                    │
                                                              portfolio fetches ────┘
```

No database, no server, no build step, no secrets. Decap runs locally against the working
tree and `git push` publishes; the only credential involved is the SSH key you already use
for git.

## Running it

```bash
./dev.sh          # starts decap-server + a static server, opens the admin in your browser
```

It waits for both servers, then opens <http://127.0.0.1:8080/admin/>. Click **Login** — the
local backend needs no credentials. Saving writes the JSON files directly. When you're happy:

```bash
node scripts/check.mjs                 # validates the content
./prune-assets.sh                      # lists images nothing references (--delete removes them)
git add -A && git commit -m "content: update projects" && git push
```

Requires `node`, `python3` and internet on first run (`npx` fetches `decap-server`, and the
admin page loads Decap from unpkg).

## Content

| File                    | What's in it                         |
| ----------------------- | ------------------------------------ |
| `content/projects.json` | Portfolio projects, in display order |
| `assets/uploads/`       | Images                               |

Shape:

```jsonc
// content/projects.json
{
  "projects": [
    {
      "title": "Hikaricon",
      "description": "A platform to discover your next favorite geek events",
      "url": "https://hikaricon.vercel.app/",
      "image_src": "/assets/uploads/hikaricon-demo.gif",
      "technologies": ["go", "next.js"],
      "isClosedSource": true,
    },
  ],
}
```

Media paths are repo-relative so the content stays portable — the portfolio prepends its own
base URL.

`node scripts/check.mjs` enforces all of that, including that every referenced image actually
exists. Run it before pushing.

Decap never removes an upload when you delete the project using it, so `assets/uploads/`
accumulates orphans. `./prune-assets.sh` lists images no content file references; add
`--delete` to remove them.

## Using it from the portfolio

Fetch at build time (SSG) — no CORS setup, no rate limits, no runtime dependency on GitHub:

```js
const BASE = "https://raw.githubusercontent.com/ThiaudioTT/cms/main";

const { projects } = await fetch(`${BASE}/content/projects.json`).then((r) =>
  r.json(),
);

const imageUrl = `${BASE}${project.image_src}`; // /assets/uploads/x.png → absolute
```

`raw.githubusercontent.com` caches for ~5 minutes, so a push shows up on the next build.

## Adding a content type

1. Create `content/<name>.json` with the initial shape.
2. Add a collection block in `admin/config.yml` pointing at it (copy the `projects` block).
3. Teach `scripts/check.mjs` what "valid" means for it.

Reusing this CMS for a different site: change `backend.repo` in `admin/config.yml` and swap
the collection blocks. Nothing else is coupled to this portfolio.

## Editing from somewhere other than your laptop

Not supported on purpose. Decap's GitHub backend needs an OAuth server holding a client
secret — GitHub requires the secret at token exchange and sends no CORS headers, so a static
admin can't authenticate on its own. The `backend:` block in `admin/config.yml` is already
correct for it; the day it's worth it, add a `base_url` pointing at a ~50-line OAuth worker
and hosted editing starts working. Until then: no secret to leak, and nothing to keep alive.

# Disclaimer?

Everything here is public data and available online!

<p align="center">
  <img src="https://safebooru.org//samples/3915/sample_567a1f5fbf0c650f9197d5621a6d85a2db3165a0.jpg?7057662" width="400" alt="">
</p>
