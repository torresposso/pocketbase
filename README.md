# PocketBase Docker Configuration for Railway

Production-ready PocketBase deployment optimized for Railway with best practices.

## Quick Deploy to Railway

1. Push this repository to GitHub
2. Connect your GitHub repo to Railway
3. Railway will auto-detect the Dockerfile
4. Set required environment variables in Railway dashboard:
   - `PORT=8080` (Railway sets this automatically)
   - `PB_ENCRYPTION_KEY` (32-char random string for settings encryption)
   - `GOMEMLIMIT=512MiB` (recommended for memory-constrained environments)

## Project Structure

```
├── Dockerfile              # Multi-stage Docker build
├── .dockerignore           # Excludes unnecessary files
├── railway.json            # Railway deployment config
├── docker-compose.yml      # Local development setup
├── .env.example            # Environment template
├── pb_migrations/          # JS migration files (commit to repo)
├── pb_hooks/               # JS hooks files (commit to repo)
└── pb_public/              # Static files (optional)
```

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PORT` | Yes | 8080 | Railway auto-sets this |
| `PB_ENCRYPTION_KEY` | No | - | 32-char key for settings encryption |
| `GOMEMLIMIT` | No | 512MiB | Memory limit for Go runtime |

## Generate PB_ENCRYPTION_KEY

```bash
# Generate a secure 32-character key
openssl rand -base64 24 | head -c 32
```

## Local Development

```bash
# Start with Docker Compose
docker-compose up -d

# Access the admin dashboard
open http://localhost:8080/_/

# View logs
docker-compose logs -f pocketbase

# Stop the container
docker-compose down
```

## Production Commands

```bash
# Build the image
docker build -t pocketbase .

# Run with custom domain (Let's Encrypt auto-certificates)
docker run -d \
  --name pocketbase \
  -p 8090:8090 \
  -v pb_data:/pb/pb_data \
  -e PB_ENCRYPTION_KEY=your_32char_key \
  pocketbase \
  /pb/pocketbase serve yourdomain.com
```

## Health Check Endpoints

| Endpoint | Description |
|----------|-------------|
| `/api/health` | Health check (used by Docker & Railway) |
| `/_/` | Admin dashboard |
| `/api/` | REST API |

## Security Best Practices

1. **Non-root user**: Container runs as `pocketbase` user
2. **Settings encryption**: Use `PB_ENCRYPTION_KEY` env var
3. **Memory limits**: Set `GOMEMLIMIT` for OOM protection
4. **Log rotation**: 50MB max, 5 files retained

## Data Persistence

| Directory | Purpose | Persistence |
|-----------|---------|-------------|
| `/pb/pb_data` | Database & uploads | Volume mounted |
| `/pb/pb_migrations` | Schema migrations | Committed to repo |
| `/pb/pb_hooks` | JavaScript hooks | Committed to repo |
| `/pb/pb_public` | Static files | Committed to repo |

## Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs pocketbase

# Verify port isn't in use
lsof -i :8080
```

### Out of memory errors
Increase `GOMEMLIMIT` in environment variables or upgrade Railway plan.

### Admin account setup
```bash
# Create superuser via CLI
docker exec -it pocketbase /pb/pocketbase superuser create email@domain.com password123
```

## Updating PocketBase

Edit `Dockerfile` and change `PB_VERSION` arg:

```dockerfile
ARG PB_VERSION=0.35.0
```

Rebuild and redeploy.
