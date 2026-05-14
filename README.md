# For Hyun

Portfolio-ready FastAPI app with Jinja2, HTMX, Alpine.js, Tailwind CSS, PostgreSQL, and Docker Compose.

## Run

```bash
docker compose up --build
```

The app runs at `http://localhost:8000`.

## Development

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build
```

Development mode enables FastAPI reload and Tailwind CSS watch.

## Database

DDL and sample data live in `ddl/`.

- `001_schema.sql`: table definitions and indexes
- `002_seed.sql`: portfolio sample data
- `bom_parts`: self-join BOM structure
- `entities`, `entity_attributes`, `entity_attribute_values`: EAV model

PostgreSQL runs SQL files from `ddl/` only when the database volume is first created.

To reset the local database:

```bash
docker compose down -v
docker compose up --build
```

## CI/CD

Pushing a tag that starts with `v` builds a Docker image, pushes it to GHCR, uploads production Compose files to the server, and restarts the service.

```bash
git tag v0.1.0
git push origin v0.1.0
```

Required GitHub repository secrets:

- `DEPLOY_HOST`: deployment server host
- `DEPLOY_USER`: SSH user
- `DEPLOY_SSH_KEY`: private SSH key for deployment
- `DEPLOY_PORT`: SSH port, defaults to `22`
- `DEPLOY_PATH`: deployment directory on the server
- `APP_PORT`: public app port, defaults to `8000`
- `DOMAIN_NAME`: deployment domain, for example `miaa9999.cafe24.com`
- `POSTGRES_USER`: PostgreSQL user
- `POSTGRES_PASSWORD`: PostgreSQL password
- `POSTGRES_DB`: PostgreSQL database name
- `GHCR_USERNAME`: optional, required when the GHCR package is private
- `GHCR_TOKEN`: optional, GitHub token or PAT with `read:packages` for private GHCR pulls

## Important Files

- `app/main.py`: FastAPI routes
- `app/templates`: Jinja2 templates
- `app/static/src/styles.css`: Tailwind input
- `docker-compose.yml`: local/prod-like Compose
- `docker-compose.dev.yml`: development override
- `docker-compose.prod.yml`: image-based deployment Compose
- `infra/caddy/Caddyfile`: Caddy reverse proxy and HTTPS config
- `.github/workflows/release-deploy.yml`: tag-based CI/CD workflow

See `docs/deployment.md` for server setup and GitHub Secrets.
