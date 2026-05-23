# LeafLens Networking Plan

All services run in a single Docker Compose stack on one VPS. Only nginx is exposed to the internet.

---

## Docker Compose

```yaml
services:
  nginx:
    image: nginx
    ports:
      - "443:443"    # HTTPS — Flutter → nginx → FastAPI
      - "1883:1883"  # MQTT  — ESP32  → nginx → ThingsBoard
    depends_on:
      - fastapi
      - thingsboard

  fastapi:
    build: .
    environment:
      - TB_URL=http://thingsboard:8080
      - TB_ADMIN_JWT=${TB_ADMIN_JWT}
      - DB_URL=postgresql://postgres:5432/leaflens
    # no ports exposed to host

  postgres:
    image: postgres:16
    # no ports exposed to host

  thingsboard:
    image: thingsboard/tb-postgres
    # no ports exposed to host
```

All services share one internal Docker network. FastAPI reaches ThingsBoard via `http://thingsboard:8080` — never through a public URL.

---

## Traffic Flow

```
Internet
   │
   ├── HTTPS :443  ──→ nginx ──→ FastAPI    (Flutter app traffic)
   └── MQTT  :1883 ──→ nginx ──→ ThingsBoard (ESP32 telemetry)

Internal Docker network only:
   FastAPI ──→ ThingsBoard :8080  (REST API calls)
   FastAPI ──→ PostgreSQL  :5432
   ThingsBoard ──→ PostgreSQL :5432  (TB's own DB)
```

---

## What Is and Isn't Exposed

| Service | Public | Notes |
|---------|--------|-------|
| nginx | Yes — 443, 1883 | Only public-facing service |
| FastAPI | No | Internal only — nginx proxies to it |
| PostgreSQL | No | Internal only |
| ThingsBoard HTTP | No | Internal only — FastAPI calls it directly |
| ThingsBoard MQTT | Via nginx :1883 | ESP32 connects here |
| ThingsBoard UI :8080 | No | Access via SSH tunnel when needed |

---

## Secrets

Secrets are injected as environment variables at runtime via a `.env` file on the host. Never baked into Docker images, never committed to source control.

```env
TB_ADMIN_JWT=...
POSTGRES_PASSWORD=...
FASTAPI_SECRET_KEY=...
```

For production, replace `.env` with a secrets manager (AWS Secrets Manager, Doppler, etc.).

---

## Accessing ThingsBoard Admin UI

ThingsBoard's UI port (8080) is not exposed. Access it via SSH tunnel:

```bash
ssh -L 8080:localhost:8080 user@your-vps
# then open http://localhost:8080 in browser
```

---

## Deployment

```bash
docker compose up -d
```

Single command brings up the full stack. All inter-service communication stays on the internal Docker network.
