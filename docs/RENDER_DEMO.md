# Hidden Room — Render + Aiven demo

## 1. Push code

Commit + push so Render builds the latest backend (includes `DB_SSL` for Aiven).

## 2. Create Web Service

1. [https://dashboard.render.com](https://dashboard.render.com) → **New** → **Web Service**
2. Connect your GitHub/Git repo
3. Settings:

| Field | Value |
|-------|--------|
| Root Directory | `backend` |
| Runtime | Node |
| Build Command | `npm install && npm run build` |
| Start Command | `npm start` |
| Instance | Free |

## 3. Environment variables

In the service → **Environment**:

```
NODE_ENV=production
PORT=10000
TZ=Asia/Kolkata

DB_HOST=<aiven-host>
DB_PORT=<aiven-port>
DB_USER=<aiven-user>
DB_PASSWORD=<aiven-password>
DB_NAME=<aiven-database>
DB_SSL=true

JWT_ACCESS_SECRET=<long-random-32+chars>
JWT_REFRESH_SECRET=<different-long-random-32+chars>
JWT_ACCESS_EXPIRES=15m
JWT_REFRESH_EXPIRES=7d

CORS_ORIGINS=*
```

Generate JWT secrets (local PowerShell):

```powershell
-join ((48..57 + 65..90 + 97..122) | Get-Random -Count 40 | ForEach-Object {[char]$_})
```

## 4. Deploy

Click **Create Web Service** / **Deploy**. Wait until it’s live.

Your API base will look like:

`https://YOUR-SERVICE.onrender.com/api/v1`

## 5. Run DB setup once

Render → your service → **Shell**:

```bash
npm install
npm run db:setup
```

That migrates + seeds (3 users, 5 units, no products).

## 6. Smoke test

Browser or curl:

```
https://YOUR-SERVICE.onrender.com/api/v1/health
```

Should return something like `{ "ok": true, ... }`.

## 7. Point the Android APK at Render

```bat
flutter build apk --dart-define=API_BASE=https://YOUR-SERVICE.onrender.com/api/v1
```

Upload that APK to Google Drive for the client.

## Notes

- Free Render **sleeps** when idle — first request after sleep can take ~30–60s.
- Seed logins: `docs/SEED_CREDENTIALS.md` (share privately).
- Local MySQL: keep `DB_SSL=false` or omit it.
