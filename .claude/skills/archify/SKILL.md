---
name: archify
description: >-
  Analyze a codebase and produce a bounded RUNTIME architecture diagram as a
  single self-contained HTML file — the moving parts as they exist when the
  system runs (services, stores, jobs, external APIs, the user's browser), not
  the folder tree. Use this whenever someone asks for an architecture diagram,
  a runtime/system/component/deployment view, a "how does this app fit
  together" picture, a data-flow or request-flow map, or wants to see the trust
  boundaries and external dependencies of a repo — even if they don't say the
  word "architecture". Prefer this over hand-drawing ad-hoc HTML: it keeps the
  diagram bounded (8–12 components, one main flow), self-contained (one file,
  opens on double-click), and always ends by printing the exact output path so
  the file is easy to find.
---

# archify — runtime architecture diagrams

Turn a repository into ONE bounded, readable picture of how the system behaves
**at runtime**, saved as a **single self-contained HTML file** that opens with a
double-click.

The value of this skill is restraint. Anyone can dump every file into a graph;
that produces a hairball nobody reads. archify's job is to find the 8–12 parts
that actually matter, draw the one flow that carries the primary work, and make
the internal/external boundary obvious. A diagram someone can hold in their head
beats an exhaustive one they close immediately.

## What "runtime" means here

Draw the system as it exists **when it is running and serving its purpose**, not
as a file listing. A `src/utils/` folder is not a runtime component; the HTTP
server, the worker that drains a queue, the Postgres instance, and the Stripe
API it calls *are*. Ask: "if I watched this system handle one real request, what
boxes would light up?" Those boxes are your components.

For a static site or a single HTML app, runtime still applies: the components
are the user's browser, the page's own modules/state, the CDN or host serving
it, and any external API or font/script origin it calls.

## The four things every archify diagram must show

1. **8–12 principal components.** No more. If you find 30 candidates, cluster
   them — collapse "auth service + session store + token cache" into one
   "Auth" box when they act as one unit at this altitude. If you find fewer
   than 8, the system may genuinely be small; that's fine, don't pad it.
2. **One main flow.** Pick the single most important path through the system
   (usually the primary user request, or the core data pipeline) and make it
   visually dominant — numbered steps and a highlighted edge color. Secondary
   flows may appear as muted edges, but only one flow is *the* flow.
3. **External dependencies.** Everything the system depends on but does not own:
   third-party APIs (payment, email, LLM, maps), managed databases, CDNs, font
   and script origins, OAuth providers. Name the real service, not "external
   API", when the repo reveals it.
4. **Trust boundaries.** Make it visually unmistakable what is *inside* the
   system's control (your services, your data) versus *outside* it (the user's
   browser, third parties, the public internet). This is the single most useful
   thing a runtime diagram conveys and the thing generic tools omit.

## Workflow

Follow these steps in order. Read `references/analysis-guide.md` before drawing —
it explains how to derive runtime components from repository evidence so the
diagram reflects the actual system, not a guess.

1. **Detect the system's shape.** Find entry points (`main`, server bootstrap,
   `index.html`, serverless handlers, `Dockerfile`/`docker-compose`,
   `Procfile`, CI/deploy config) and the dependency manifest (`package.json`,
   `requirements.txt`, `go.mod`, `pom.xml`, etc.). These tell you what actually
   runs and what it talks to. Grep for outbound calls (`fetch`, `http`, SDK
   client constructors, connection strings, env vars like `*_API_KEY`,
   `*_URL`, `DATABASE_URL`) to find external dependencies.
2. **List candidate components, then cut to 8–12.** Group by runtime role, not
   by folder. Merge things that co-deploy and co-fail. Keep the user/client as
   a component when there is one.
3. **Choose the one main flow** and number its steps (1, 2, 3 …).
4. **Place each component inside or outside the trust boundary.**
5. **Fill the template** at `assets/template.html` (see below) and write the
   result to a file.
6. **Print the exact output path.** Always end your response with the absolute
   path of the HTML file on its own line, clearly labeled — see "Reporting the
   output" below. This is not optional courtesy: files created from the console
   do not always surface on their own in the client's file view, so the user
   needs the literal path to open it.

## Building the file

Use `assets/template.html` as the base. It is a complete, self-contained,
theme-aware HTML page (inline CSS, no external network requests, no build step)
with clearly marked placeholders for the title, the component boxes, the flow
edges, the legend, and the trust-boundary regions. Filling the template — rather
than hand-writing a new page each time — keeps every diagram legible, consistent,
and genuinely single-file.

Hard requirements for the output file, because the whole point is a file the user
can double-click and trust:

- **One file, zero external requests.** All CSS inline. No `<script src>` to a
  CDN, no external stylesheet, no remote fonts — use a system font stack. If the
  diagram needs a library, inline it; prefer plain inline SVG + CSS, which needs
  none. A file that phones out breaks when opened offline and defeats the point.
- **Self-explaining.** Include a short legend that decodes the colors/shapes,
  and a one-line caption naming the main flow. Someone who never saw the repo
  should grasp the picture in under a minute.
- **Both themes.** The template already handles light and dark via
  `prefers-color-scheme`; keep colors as the template's CSS variables so it
  stays readable either way.
- **Draw with inline SVG** for the boxes-and-arrows. It scales, prints, and
  needs nothing external. The template shows the pattern.

Save the file with a descriptive name next to the repo (e.g.
`architecture.html`, or `<project>-runtime-architecture.html`). If the user gave
a location or name, honor it.

## Reporting the output

End every run with the path, formatted exactly like this so it is impossible to
miss:

```
Diagram saved to: /absolute/path/to/architecture.html
Open it by double-clicking the file, or run: open /absolute/path/to/architecture.html
```

Use the real absolute path. If you know the user's platform, give the matching
open command (`open` on macOS, `xdg-open` on Linux, `start` on Windows);
otherwise `open` plus the double-click instruction is fine.

## Scope discipline (why the limits matter)

The 8–12 / one-flow limits are the skill, not red tape. A runtime diagram earns
its keep by being the thing a new engineer opens on day one and an architect
sketches from memory. Every extra box past ~12 costs more comprehension than it
adds information. When you feel the urge to add a thirteenth component, cluster
instead, or ask whether it belongs in a separate, more detailed diagram. If the
user explicitly wants exhaustive detail, say that a second focused diagram (e.g.
just the data layer) reads better than one crowded one, and offer to make it.
