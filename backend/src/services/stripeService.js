import Stripe from 'stripe';
import prisma from '../prisma/client.js';
import { AppError } from '../utils/AppError.js';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

/**
 * Creates a Stripe checkout session for a given workspace and plan.
 * @param {number} workspaceId - The ID of the workspace.
 * @param {string} planSlug - The slug of the plan to subscribe to.
 * @param {string} successUrl - The URL to redirect to on successful payment.
 * @param {string} cancelUrl - The URL to redirect to on canceled payment.
 * @returns {Promise<Stripe.Checkout.Session>}
 */
export const createCheckoutSession = async (workspaceId, planSlug, successUrl, cancelUrl) => {
  const plan = await prisma.plan.findUnique({ where: { slug: planSlug } });
  if (!plan || !plan.stripePriceId) {
    throw new AppError('Plan not found or not configured for Stripe.', 404);
  }

  const workspace = await prisma.workspace.findUnique({
    where: { id: workspaceId },
    include: { owner: true },
  });
  if (!workspace) {
    throw new AppError('Workspace not found.', 404);
  }

  let customerId;
  // This is a simplified customer management. In a real app, you'd want to
  // store the stripeCustomerId on your User or Workspace model.
  const existingCustomers = await stripe.customers.list({ email: workspace.owner.email, limit: 1 });
  if (existingCustomers.data.length > 0) {
    customerId = existingCustomers.data[0].id;
  } else {
    const newCustomer = await stripe.customers.create({
      email: workspace.owner.email,
      name: workspace.owner.name,
      metadata: { workspaceId: workspace.id },
    });
    customerId = newCustomer.id;
  }

  const session = await stripe.checkout.sessions.create({
    payment_method_types: ['card'],
    customer: customerId,
    line_items: [{
      price: plan.stripePriceId,
      quantity: 1,
    }],
    mode: 'subscription',
    success_url: successUrl,
    cancel_url: cancelUrl,
    metadata: {
      workspaceId: workspaceId,
      planId: plan.id,
    },
  });

  return session;
};

/**
 * Handles Stripe webhook events.
 * @param {object} event - The Stripe webhook event.
 */
export const handleWebhookEvent = async (event) => {
  switch (event.type) {
    case 'checkout.session.completed':
      await _handleCheckoutSessionCompleted(event.data.object);
      break;
    case 'invoice.payment_succeeded':
      await _handleInvoicePaymentSucceeded(event.data.object);
      break;
    case 'invoice.payment_failed':
      await _handleInvoicePaymentFailed(event.data.object);
      break;
    case 'customer.subscription.updated':
      await _handleSubscriptionUpdated(event.data.object);
      break;
    case 'customer.subscription.deleted':
      await _handleSubscriptionDeleted(event.data.object);
      break;
    default:
      console.log(`Unhandled Stripe event type: ${event.type}`);
  }
};

const _handleCheckoutSessionCompleted = async (session) => {
  const { workspaceId, planId } = session.metadata;
  const stripeSubscriptionId = session.subscription;

  const subscriptionData = await stripe.subscriptions.retrieve(stripeSubscriptionId);

  await prisma.subscription.create({
    data: {
      workspaceId: parseInt(workspaceId),
      planId: parseInt(planId),
      stripeSubscriptionId,
      status: subscriptionData.status.toUpperCase(),
      currentPeriodEnd: new Date(subscriptionData.current_period_end * 1000),
      trialEnd: subscriptionData.trial_end ? new Date(subscriptionData.trial_end * 1000) : null,
    },
  });
};

const _handleInvoicePaymentSucceeded = async (invoice) => {
    if(!invoice.subscription) return;
  const subscription = await prisma.subscription.findUnique({
    where: { stripeSubscriptionId: invoice.subscription },
  });

  if (subscription) {
    await prisma.payment.create({
      data: {
        subscriptionId: subscription.id,
        stripeInvoiceId: invoice.id,
        amount: invoice.amount_paid / 100,
        currency: invoice.currency,
        status: 'SUCCEEDED',
        paidAt: new Date(invoice.status_transitions.paid_at * 1000),
        invoicePdf: invoice.invoice_pdf,
      },
    });

    // Ensure subscription is marked as active
    await prisma.subscription.update({
        where: { id: subscription.id },
        data: { status: 'ACTIVE' }
    });
  }
};

const _handleInvoicePaymentFailed = async (invoice) => {
    if(!invoice.subscription) return;
    const subscription = await prisma.subscription.findUnique({
        where: { stripeSubscriptionId: invoice.subscription },
    });

    if(subscription) {
        await prisma.subscription.update({
            where: { id: subscription.id },
            data: { status: 'PAST_DUE' }
        });
    }
};

const _handleSubscriptionUpdated = async (stripeSubscription) => {
  const subscription = await prisma.subscription.findUnique({
    where: { stripeSubscriptionId: stripeSubscription.id },
  });

  if (subscription) {
    await prisma.subscription.update({
      where: { id: subscription.id },
      data: {
        status: stripeSubscription.status.toUpperCase(),
        currentPeriodEnd: new Date(stripeSubscription.current_period_end * 1000),
        cancelAtPeriodEnd: stripeSubscription.cancel_at_period_end,
        canceledAt: stripeSubscription.canceled_at ? new Date(stripeSubscription.canceled_at * 1000) : null,
        trialEnd: stripeSubscription.trial_end ? new Date(stripeSubscription.trial_end * 1000) : null,
      },
    });
  }
};

const _handleSubscriptionDeleted = async (stripeSubscription) => {
  const subscription = await prisma.subscription.findUnique({
    where: { stripeSubscriptionId: stripeSubscription.id },
  });

  if (subscription) {
    await prisma.subscription.update({
      where: { id: subscription.id },
      data: {
        status: 'CANCELED',
        canceledAt: new Date(),
      },
    });
  }
};

/**
 * Creates a Stripe customer portal session for a given workspace.
 * @param {number} workspaceId - The ID of the workspace.
 * @param {string} returnUrl - The URL to redirect to after the portal session.
 * @returns {Promise<Stripe.BillingPortal.Session>}
 */
export const createCustomerPortalSession = async (workspaceId, returnUrl) => {
  const subscription = await prisma.subscription.findUnique({
    where: { workspaceId },
  });

  if (!subscription) {
    throw new AppError('Subscription not found for this workspace.', 404);
  }

  const checkoutSession = await stripe.checkout.sessions.list({
    subscription: subscription.stripeSubscriptionId,
    limit: 1,
  });

  if (checkoutSession.data.length === 0) {
    throw new AppError('Could not find original checkout session.', 500);
  }

  const customerId = checkoutSession.data[0].customer;

  const portalSession = await stripe.billingPortal.sessions.create({
    customer: customerId,
    return_url: returnUrl,
  });

  return portalSession;
};
