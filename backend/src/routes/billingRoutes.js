import express from 'express';
import {
  createCheckoutSession,
  handleWebhookEvent,
  createCustomerPortalSession,
} from '../services/stripeService.js';
import { AppError } from '../utils/AppError.js';
import { protect } from '../middleware/authMiddleware.js';

const router = express.Router();

// Route to create a checkout session
router.post('/create-checkout-session', protect, async (req, res, next) => {
  try {
    const { workspaceId, planSlug, successUrl, cancelUrl } = req.body;
    if (!workspaceId || !planSlug || !successUrl || !cancelUrl) {
      return next(new AppError('Missing required parameters.', 400));
    }
    const session = await createCheckoutSession(workspaceId, planSlug, successUrl, cancelUrl);
    res.json({ sessionId: session.id, url: session.url });
  } catch (error) {
    next(error);
  }
});

// Route for Stripe webhooks
router.post('/webhook', express.raw({ type: 'application/json' }), async (req, res, next) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  try {
    await handleWebhookEvent(event);
    res.status(200).json({ received: true });
  } catch (error) {
    next(error);
  }
});

// Route to create a customer portal session
router.post('/create-customer-portal-session', protect, async (req, res, next) => {
  try {
    const { workspaceId, returnUrl } = req.body;
    if (!workspaceId || !returnUrl) {
        return next(new AppError('Missing required parameters.', 400));
    }
    const portalSession = await createCustomerPortalSession(workspaceId, returnUrl);
    res.json({ url: portalSession.url });
  } catch (error) {
    next(error);
  }
});

export default router;
