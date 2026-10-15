import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import { config } from './config';
import { errorHandler } from './middleware/errorHandler';
import { v1 } from './routes/v1';

export function createApp() {
  const app = express();
  app.use(helmet());
  app.use(
    cors({
      origin: (origin, cb) => {
        if (!origin) return cb(null, true);
        const ok = config.corsOrigins.some((pattern) => {
          if (pattern.endsWith('*')) return origin.startsWith(pattern.slice(0, -1));
          return origin === pattern;
        });
        cb(null, ok);
      },
    }),
  );
  app.use(express.json({ limit: '1mb' }));
  app.use('/api/v1', v1);
  app.use(errorHandler);
  return app;
}
