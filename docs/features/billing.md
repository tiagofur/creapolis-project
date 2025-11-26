# Billing and Subscriptions

This document describes the billing and subscriptions feature in Creapolis.

## Overview

The billing and subscriptions feature allows users to subscribe to different plans to access more features and higher limits. The feature is implemented using Stripe.

## Backend

### Prisma Models

The following models have been added to the `schema.prisma` file:

- `Plan`: Represents a subscription plan (e.g., Free, Pro, Enterprise).
- `Subscription`: Represents a workspace's subscription to a plan.
- `Payment`: Represents a payment made for a subscription.

### Stripe Service

The `stripeService.js` file (`backend/src/services/stripeService.js`) contains the logic for interacting with the Stripe API. It provides the following functions:

- `createCheckoutSession`: Creates a Stripe checkout session for a given workspace and plan.
- `handleWebhookEvent`: Handles Stripe webhook events.
- `createCustomerPortalSession`: Creates a Stripe customer portal session for a given workspace.

### API Routes

The following API routes have been added to `billingRoutes.js` (`backend/src/routes/billingRoutes.js`):

- `POST /api/billing/create-checkout-session`: Creates a checkout session.
- `POST /api/billing/webhook`: Handles Stripe webhooks.
- `POST /api/billing/create-customer-portal-session`: Creates a customer portal session.

### Middleware

The `planMiddleware.js` file (`backend/src/middleware/planMiddleware.js`) provides a middleware to check if a workspace has an active subscription and if the current usage is within the plan's limits.

## Frontend (Flutter)

### Screens

The following screens have been added:

- `PlansScreen`: Displays the available subscription plans.
- `CheckoutScreen`: Displays the Stripe checkout page in a `WebView`.
- `SubscriptionManagementScreen`: Displays the current subscription and a button to manage it.

### Services

The `BillingService` (`creapolis_app/lib/data/services/billing_service.dart`) provides methods to interact with the billing API.

### Providers

The `SubscriptionProvider` (`creapolis_app/lib/presentation/providers/subscription_provider.dart`) holds the current subscription state and provides methods to check the plan limits.
