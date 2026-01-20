import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { initFirebase } from './services/firebase.js';
import { createStripePaymentIntent } from './services/stripe.js';

const app = express();
const port = process.env.PORT || 8080;

initFirebase();

app.use(express.json({ limit: '1mb' }));
app.use(
  cors({
    origin: (origin, callback) => {
      const allowed = (process.env.ALLOWED_ORIGINS || '').split(',');
      if (!origin || allowed.includes(origin)) {
        return callback(null, true);
      }
      return callback(new Error('Not allowed by CORS'));
    },
  })
);

app.get('/health', (_, res) => {
  res.json({ status: 'ok', time: new Date().toISOString() });
});

app.post('/payments/create-intent', async (req, res) => {
  try {
    const { amount, currency = 'usd', metadata = {} } = req.body || {};
    if (!amount || amount <= 0) {
      return res.status(400).json({ error: 'Amount must be > 0' });
    }
    const intent = await createStripePaymentIntent({ amount, currency, metadata });
    return res.json({ clientSecret: intent.client_secret });
  } catch (error) {
    return res.status(500).json({ error: error.message || 'Failed to create intent' });
  }
});

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`Backend running on http://localhost:${port}`);
});
