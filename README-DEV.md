# Pretix — Run from Source with Docker (Dev)

## 1) Clone Pretix
```bash
git clone https://github.com/pretix/pretix.git
cd pretix
```

## 2) Copy this kit into the repo root
Place these files at the root of the cloned repo:
- Dockerfile.dev
- docker-compose.dev.yml
- docker/entrypoint.dev.sh
- .env.example (optional)

## 3) Start
```bash
docker compose -f docker-compose.dev.yml up -d --build
```
Open http://localhost:8080

## 4) Dev tips
- Code edits apply immediately (repo is mounted into /app).
- Rebuild after dependency changes:
```bash
docker compose -f docker-compose.dev.yml up -d --build
```
- Logs:
```bash
docker compose -f docker-compose.dev.yml logs -f web
```
- Django shell:
```bash
docker compose -f docker-compose.dev.yml exec web python manage.py shell
```
- Stop / reset:
```bash
docker compose -f docker-compose.dev.yml down
docker compose -f docker-compose.dev.yml down -v   # wipes DB/media
```

## 5) Apple Silicon
If you see platform warnings, add `platform: linux/amd64` under each service.
