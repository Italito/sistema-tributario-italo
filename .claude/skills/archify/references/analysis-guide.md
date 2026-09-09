# Deriving runtime components from a repository

The goal is a diagram that reflects what the system *actually does when it runs*,
grounded in evidence from the repo — not an idealized or guessed architecture.
Read this before drawing.

## 1. Find what runs (entry points)

The runtime components are anchored by entry points. Look for, in rough order:

- **Web/app server bootstrap**: `app.listen`, `createServer`, `FastAPI()`,
  `Flask(__name__)`, `express()`, `next` config, `main()` that starts a server.
- **Static/browser entry**: `index.html`, a single-page app root, a `<script
  type="module">` that boots the UI. For these, the browser itself is a runtime
  component and often the only "compute" node.
- **Background work**: queue consumers, cron/scheduled jobs, workers
  (`worker.js`, Celery tasks, `@Scheduled`, `sidekiq`).
- **Serverless/functions**: `handler` exports, `functions/` dirs,
  `netlify/`, `api/` route files, cloud function manifests.
- **Container/deploy descriptors**: `Dockerfile`, `docker-compose.yml`,
  `Procfile`, `k8s/*.yaml`, `vercel.json`, `render.yaml`. Each service defined
  here is usually a runtime component, and the file reveals how they connect.

Each distinct runnable thing is a candidate component. A library or util module
that only runs *inside* one of these is not its own component.

## 2. Find what it talks to (dependencies & external calls)

External dependencies are the highest-signal, most-often-omitted part. Find them:

- **Dependency manifest**: `package.json`, `requirements.txt`, `go.mod`,
  `pom.xml`, `Gemfile`, `composer.json`. SDK packages reveal external services
  (e.g. `stripe`, `@aws-sdk/*`, `openai`, `pg`, `redis`, `nodemailer`,
  `twilio`, `googleapis`).
- **Outbound calls in code**: grep for `fetch(`, `axios`, `http.get`,
  `requests.`, `HttpClient`, SDK client constructors (`new Stripe(`,
  `createClient(`, `OpenAI(`).
- **Connection strings & config**: env vars such as `DATABASE_URL`, `REDIS_URL`,
  `*_API_KEY`, `*_ENDPOINT`, `*_URL`; `.env.example`, config files. These name
  the datastores and third-party APIs.
- **Frontend origins**: `<link href="https://fonts.googleapis.com...">`,
  `<script src="https://cdn...">`, `fetch('https://api.some-service...')`. Each
  distinct external origin is an external dependency and lives *outside* the
  trust boundary.

Name the real service when the repo reveals it (Stripe, Postgres, S3, OpenAI,
Google Fonts) rather than a generic "external API" — specificity is what makes
the diagram useful.

## 3. Cluster to 8–12

You will usually find more candidates than fit. Cluster by **runtime role and
shared fate**, not by folder:

- Things that deploy together and fail together become one box (an API server
  plus its in-process cache and router = "API").
- A datastore and its read replica = one "Database" box unless the replica is
  architecturally important to the story.
- Many similar external providers can be one box labeled by category ("Email /
  SMS providers") if naming each adds noise.

Keep the **user/client** as its own component whenever a human or external caller
initiates the flow — it anchors the trust boundary.

If after clustering you have fewer than 8, the system is simply small. Do not
invent components to hit a number; an honest 6-box diagram beats a padded one.

## 4. Identify the one main flow

Trace the single most important path end to end. Typically:

- **Web app**: User → frontend → API → datastore → back, plus the one external
  call that matters most (auth, payment, LLM).
- **Data pipeline**: source → ingest → transform → store → serve.
- **Static/single-file app**: User action in browser → local state/logic →
  render, plus any external fetch.

Number the steps. Everything else is secondary and should be visually quieter.

## 5. Place the trust boundary

Draw a clear region (or two) separating:

- **Inside** — what the system owns and controls: its own services, its own
  databases, its own jobs.
- **Outside** — what it does not control: the user's browser/device, third-party
  APIs, managed services it merely calls, the public internet, CDNs.

When in doubt: if the team could break it by pushing bad code, it's inside; if it
would keep working (or fail independently) regardless of their deploy, it's
outside. This line is often the most informative thing in the whole diagram.

## Evidence discipline

Prefer what the repo shows over what you'd expect. If you infer a component or a
dependency that isn't clearly evidenced (e.g. "there's probably a cache"), either
confirm it in the code or leave it out. A diagram the reader can trust against
the actual codebase is worth more than a plausible-looking one that doesn't match.
