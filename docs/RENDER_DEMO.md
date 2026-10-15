# CafeCount — Render demo notes

## API on Render

1. Create a **Web Service** from `backend/`
2. Build: `npm install && npm run build`
3. Start: `npm start`
4. Add **MySQL** (Render managed DB or external) and set env:

```
NODE_ENV=production
PORT=10000
DB_HOST=...
DB_PORT=3306
DB_USER=...
DB_PASSWORD=...
DB_NAME=cafecount
JWT_ACCESS_SECRET=<long random>
JWT_REFRESH_SECRET=<long random>
CORS_ORIGINS=*
TZ=Asia/Kolkata
```

5. Run migrations once (Render shell or release command):

```
npm run db:setup
```

## Flutter pointing at Render

```bat
flutter run --dart-define=API_BASE=https://YOUR-SERVICE.onrender.com/api/v1
```

Free Render web services sleep when idle — first request may be slow.
