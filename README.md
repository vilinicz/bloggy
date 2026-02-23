# Bloggy

Bloggy - post & discuss.

- Backend: Rails API + PostgreSQL
- Frontend: Angular SPA
- Dev process manager: Overmind (`Procfile.dev` in repo root)

## Features

- Create articles (`title`, `body`, `author_name`)
- Articles feed with newest-first order and infinite scroll
- Article details page with comments list and comment form
- Comments counter via `counter_cache`
- Engagement overview:
  - total articles
  - total comments
  - most commented articles

## Project structure

- `backend` - Rails API
- `frontend` - Angular app
- `Procfile.dev` - runs backend + frontend together
- `prd.md` - implementation proposal/spec

## Requirements

- Ruby `3.4.7`
- Node.js `22.14.0` (Angular CLI requires `>= 22.12.0`)
- npm `10.9.2`
- PostgreSQL running locally (default port `5432`)

## Setup

#### Install backend dependencies:

```bash
cd backend
bundle install
```

#### Install frontend dependencies:

```bash
cd ../frontend
npm install
```

#### Prepare database and run migrations:

```bash
cd ../backend
bundle exec rails db:prepare
```

#### Seed demo data:
```bash
bundle exec rails db:seed
```
Creates 50 articles with up to 600 comments

## Seed data behavior

Seeds generate realistic demo content using `faker`:

- exactly `50` articles
- for each article: `2..600` comments
- the most recently created article (first in feed) always has `> 500` comments
- article body has `3..5` paragraphs
- realistic author names, titles, bodies, and comment text

## Run in development

From repository root:

```bash
BUNDLE_GEMFILE=backend/Gemfile bundle exec overmind start -f Procfile.dev
```

Services:

- Frontend: `http://localhost:4200`
- Backend API: `http://localhost:3000`

`CORS` is configured in backend to allow `http://localhost:4200` by default.

## Tests

Backend (RSpec):

```bash
cd backend
bundle exec rspec
```

Frontend (Vitest via Angular CLI):

```bash
cd frontend
npm test -- --watch=false
```

## Build frontend

```bash
cd frontend
npm run build
```

Build output: `frontend/dist/frontend`

## API endpoints

Base path: `/api`

- `GET /api/articles?limit=20`
- `GET /api/articles?limit=20&cursor=...`
- `POST /api/articles`
- `GET /api/articles/:id`
- `GET /api/articles/:article_id/comments?limit=30`
- `GET /api/articles/:article_id/comments?limit=30&cursor=...`
- `POST /api/articles/:article_id/comments`
- `GET /api/overview`

## Miscellaneous

### Time spent
- 4 hours spread over 3 days: 
  - Saturday 15 minutes - read the task 
  - Sunday 3 hours - planning & implementation 
  - Monday 30 minutes - review, Readme and push  

### Next steps  
- caching on backend 
- maybe SSR with Cloudflare caching
- production deployment setup (possibly with Docker compose)
- better design =D
- introduce .env with common settings
- for /overview it's better to store stats in materialized view or use similar approach. Or at least refactor to single SQL query
- clear up frontend app: I'd like to extract article card to separate component, make better error handling

### Notes
- Actually I'd prefer to use Rails' default Hotwire stack for this project, with real-time updates out of the box, view caching, etc..
- Keyset pagination is implemented with Pagy and ordering `created_at DESC, id DESC` - my decision, I think that infinite scroll works best with it
