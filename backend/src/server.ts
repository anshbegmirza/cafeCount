import { createApp } from './app';
import { config } from './config';

process.env.TZ = config.tz;

const app = createApp();
app.listen(config.port, () => {
  console.log(`${config.appName} API listening on http://localhost:${config.port}`);
});
