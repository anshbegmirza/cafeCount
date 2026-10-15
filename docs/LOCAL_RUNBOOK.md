# CafeCount — local runbook

Timezone: Asia/Kolkata

## 1. MySQL

Service `MySQL84` should be Running.

```bat
"C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -u root -e "CREATE DATABASE IF NOT EXISTS cafecount;"
```

## 2. API

```bat
cd backend
npm run db:setup
npm run dev
```

Health check: http://localhost:3000/api/v1/health

## 3. Flutter / emulator

```bat
set PATH=C:\src\flutter\bin;%PATH%
cd mobile
flutter pub get
flutter devices
flutter run
```

Log in with seed users from `SEED_CREDENTIALS.md`.

## 4. Language / theme

- Language toggle in app bar (EN ↔ AR, RTL)
- Theme follows system light/dark
