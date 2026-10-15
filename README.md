# CafeCount

Coffee shop stock management — Flutter + Express + MySQL.

## Stack

- `mobile/` — Flutter (Android first; iOS later)
- `backend/` — Express + TypeScript + Knex + MySQL
- EN + Arabic (RTL), theme `#28C8FF`, light/dark

## Prerequisites

- Node.js 20+
- MySQL 8 running
- Flutter SDK (`C:\src\flutter` on this machine)
- Android Studio / Android SDK + emulator

## Backend

```bash
cd backend
copy .env.example .env   # Windows: copy
npm install
npm run db:setup
npm run dev
```

API: `http://localhost:3000/api/v1`

Seed logins: see [docs/SEED_CREDENTIALS.md](docs/SEED_CREDENTIALS.md)

## Mobile

```bash
cd mobile
flutter pub get
flutter run
```

Emulator API base defaults to `http://10.0.2.2:3000/api/v1`.

For Render demo:

```bash
flutter run --dart-define=API_BASE=https://YOUR-API.onrender.com/api/v1
```

## Agent docs

See `AGENTS.md` and `.cursor/rules/`.
