# Deployment Guide

This project deploys with GitHub Actions, GHCR, Docker Compose, FastAPI, and PostgreSQL.

## Do I need to install PostgreSQL on the server?

No. PostgreSQL runs as a Docker container from `postgres:15`.

The server only needs:

- Docker Engine
- Docker Compose plugin
- SSH access from GitHub Actions
- An open app port, usually `8000`
- Open `80` and `443` ports when using the domain with HTTPS

## Server setup

Run these commands on the deployment server.

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"
```

Log out and back in after `usermod`.

Create the deploy directory:

```bash
mkdir -p ~/apps/mia-pofo
```

## SSH key for GitHub Actions

Create a deploy key on your local machine.

```bash
ssh-keygen -t ed25519 -C "github-actions-mia-pofo" -f ./mia-pofo-deploy-key
```

Copy the public key to the server.

```bash
ssh-copy-id -i ./mia-pofo-deploy-key.pub USER@HOST
```

The private key content goes into the `DEPLOY_SSH_KEY` GitHub secret.

## GitHub repository secrets

Go to:

`GitHub repository > Settings > Secrets and variables > Actions > New repository secret`

Add these required secrets:

| Secret | Example | Notes |
| --- | --- | --- |
| `DEPLOY_HOST` | `your.server.ip` | Server IP or domain |
| `DEPLOY_USER` | `ubuntu` | SSH user |
| `DEPLOY_SSH_KEY` | private key content | Content of `mia-pofo-deploy-key` |
| `DEPLOY_PATH` | `/home/ubuntu/apps/mia-pofo` | Directory on server |
| `DOMAIN_NAME` | `miaa9999.cafe24.com` | Domain for Caddy HTTPS |
| `POSTGRES_USER` | `mia` | PostgreSQL user inside Docker |
| `POSTGRES_PASSWORD` | strong password | Do not commit this |
| `POSTGRES_DB` | `mia_pofo` | Database name |

Optional secrets:

| Secret | Example | Notes |
| --- | --- | --- |
| `DEPLOY_PORT` | `22` | SSH port |
| `APP_PORT` | `8000` | Legacy direct app port, not used by Caddy deployment |
| `GHCR_USERNAME` | `miaa9999` | Needed if GHCR package is private |
| `GHCR_TOKEN` | GitHub PAT | Needs `read:packages` for private GHCR pulls |

## GHCR visibility

The workflow pushes images to:

```text
ghcr.io/miaa9999/mia-pofo:<tag>
```

If the GHCR package is public, the server can pull without `GHCR_USERNAME` and `GHCR_TOKEN`.

If the GHCR package is private, create a GitHub Personal Access Token with `read:packages`, then set:

- `GHCR_USERNAME`
- `GHCR_TOKEN`

## Deploy

After secrets are set:

```bash
git tag v0.1.0
git push origin v0.1.0
```

GitHub Actions will build, push, upload Compose files, and run:

```bash
docker compose pull
docker compose up -d
```

After deployment, open:

```text
https://miaa9999.cafe24.com
```

Caddy automatically issues and renews the HTTPS certificate as long as ports `80` and `443` are reachable from the internet.

## Database initialization

The first deployment creates the PostgreSQL volume and runs SQL files from `ddl/`.

After that, SQL files are not automatically rerun unless the DB volume is removed.

For production, do not remove the volume unless you intentionally want to wipe the database.
