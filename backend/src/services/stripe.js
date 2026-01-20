import Stripe from 'stripe';

const stripeKey = process.env.STRIPE_SECRET_KEY || '';
const stripe = stripeKey ? new Stripe(stripeKey) : null;

export async function createStripePaymentIntent({ amount, currency, metadata }) {
  if (!stripe) {
    throw new Error('Stripe secret key is missing');
  }
  return stripe.paymentIntents.create({
    amount,
    currency,
    metadata,
    automatic_payment_methods: { enabled: true },
  });
}
