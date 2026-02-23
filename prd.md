# Bloggy -- Product Requirements Document (PRD)

## 1. Overview

Bloggy is a public message board web application consisting of:

-   **Backend:** Rails 8.1.0 (API-only), PostgreSQL
-   **Frontend:** Angular 21.1.0 (SPA)
-   **Monorepo structure:**
    -   `/backend`
    -   `/frontend`

The application allows visitors (no authentication) to:

-   View a feed of articles with infinite scrolling
-   View a single article
-   Add comments to articles (with infinite scrolling)
-   Create new articles
-   View engagement statistics overview

No authentication or user accounts are required. `author_name` is a
free-text field.

------------------------------------------------------------------------

## 2. High-Level Architecture

### Backend

-   Rails API mode
-   PostgreSQL database
-   Pagination using Pagy with keyset pagination
-   Comment count using counter_cache
-   RESTful controllers
-   Overview logic encapsulated in a Query object

### Frontend

-   Angular SPA
-   Infinite scrolling for:
    -   Articles feed
    -   Comments on article page
-   Minimal, clean UI
-   Use a lightweight popular CSS framework (e.g., Pico.css or Bootstrap
    5 without JS dependency)

------------------------------------------------------------------------

## 3. Domain Model

### Article

Fields: - id (bigint, primary key) - title (string, required, max 200
chars) - body (text, required) - author_name (string, required, max 100
chars) - comments_count (integer, default 0, not null) - created_at -
updated_at

### Comment

Fields: - id (bigint, primary key) - article_id (foreign key,
required) - body (text, required) - author_name (string, required, max
100 chars) - created_at - updated_at

Relationships: - Article has_many comments - Comment belongs_to article,
counter_cache: true

------------------------------------------------------------------------

## 4. Database Indexes (PostgreSQL)

### Articles

INDEX index_articles_on_created_at_desc_id_desc ON articles (created_at
DESC, id DESC);

INDEX index_articles_on_comments_count ON articles (comments_count);

### Comments

INDEX index_comments_on_article_id_created_at_desc_id_desc ON comments
(article_id, created_at DESC, id DESC);

------------------------------------------------------------------------

## 5. Pagination Strategy

Sorting order:

ORDER BY created_at DESC, id DESC

Cursor parameter: - cursor (opaque token from previous response)

API must return: - items - next_cursor (or null)

------------------------------------------------------------------------

## 6. API Endpoints

All endpoints under /api.

### Articles Feed

GET /api/articles?limit=20 GET
/api/articles?limit=20&cursor=...

### Create Article

POST /api/articles

Body: - title - body - author_name

### View Article

GET /api/articles/:id

### Comments Feed

GET /api/articles/:article_id/comments?limit=30 GET
/api/articles/:article_id/comments?limit=30&cursor=...

### Create Comment

POST /api/articles/:article_id/comments

### Overview

GET /api/overview

Returns: - total_articles - total_comments - most_commented_articles
(top 5)

------------------------------------------------------------------------

## 7. Backend Structure

Controllers: - Api::ArticlesController - Api::CommentsController -
Api::OverviewController

Query object: - app/queries/overview_query.rb

------------------------------------------------------------------------

## 8. Frontend Pages

1.  /articles -- Articles feed
2.  /articles/new -- Create article
3.  /articles/:id -- Article + comments
4.  /overview -- Statistics

------------------------------------------------------------------------

## 9. Comment Form Placement

On article page: - Article content - "Comments (N)" - Comment form -
Comments list (newest first)

------------------------------------------------------------------------

## 10. Validation Rules

Article: - title required, max 200 - body required - author_name
required, max 100

Comment: - body required - author_name required, max 100

Return 422 JSON errors on validation failure.

------------------------------------------------------------------------

## 11. UI Acceptance Criteria

Article UI requirements:

-   Article entries in the feed must display: `title`, `author_name`,
    `created_at`, `comments_count`

Comment UI requirements:

-   Comment entries on the article page must display: `body`,
    `author_name`, `created_at`

------------------------------------------------------------------------

## 12. Testing Requirements

Backend tests must use RSpec.

Required test coverage:

-   Request specs for API endpoints
-   Model specs for Article and Comment validations/associations
-   Counter cache verification (`comments_count` updates correctly when
    creating comments)

------------------------------------------------------------------------

## 13. Seed Data

Seed data must be provided for local development/demo.

Requirements:

-   Create 50 articles
-   For each article, create from 2 to 600 comments
-   The most recently created article (first item in the frontend
    articles feed) must have more than 500 comments (mandatory)
-   Seed content must look realistic (human-like), not random gibberish
    or meaningless character sequences
-   Each article must include:
    -   a realistic title
    -   author name
    -   body with 3 to 5 paragraphs
-   Each comment must include:
    -   realistic comment text
    -   comment author name

Implementation guidance:

-   Use `faker` (or similar library) to generate names and readable text
-   `factory_bot_rails` may be used to structure seed generation and keep
    seed code maintainable

------------------------------------------------------------------------

## 14. Development Run (Dev Mode)

For local development, use the root-level `Procfile.dev`.

Start the project from the repository root using:

-   `overmind start -f Procfile.dev`

------------------------------------------------------------------------

## 15. Non-Functional Requirements

-   No N+1 queries
-   Deterministic pagination
-   Efficient indexes
-   Clean JSON responses
-   Ruby on Rails styleguide
-   Frontend code must follow the official Angular Style Guide
    (`angular.dev/style-guide`)
-   Angular code quality must be enforced with `@angular-eslint`
    recommended rules and TypeScript/template strict mode enabled
-   KISS, DRY principles

------------------------------------------------------------------------

## 16. Out of Scope

-   Authentication
-   Editing/deleting content
-   Real-time updates
