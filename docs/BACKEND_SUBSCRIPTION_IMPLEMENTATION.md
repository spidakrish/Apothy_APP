# Backend Subscription Implementation Guide

This document provides a comprehensive guide for implementing the backend infrastructure required to support the Apothy mobile app's premium subscription system.

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Database Schema](#database-schema)
4. [RevenueCat Webhook Handler](#revenuecat-webhook-handler)
5. [API Endpoints](#api-endpoints)
6. [Security Considerations](#security-considerations)
7. [Testing Strategy](#testing-strategy)
8. [Deployment Checklist](#deployment-checklist)

---

## Overview

The Apothy mobile app uses RevenueCat for in-app purchase management. The backend's role is to:

1. **Receive webhook events** from RevenueCat when subscriptions change
2. **Store subscription state** in the database alongside user records
3. **Serve subscription data** to the mobile app via authenticated API endpoints
4. **Validate subscription status** for feature access control

### Subscription Tiers

| Tier | Price (Monthly) | Price (Yearly) | Features |
|------|----------------|----------------|----------|
| **Free** | $0 | $0 | 5 emotion challenges/month, basic chat, last 50 messages, 4 achievements |
| **Plus** | $9.99 | $79.99 | Unlimited challenges, full XP, unlimited history, all achievements, cloud sync, analytics |
| **Pro** | $19.99 | $159.99 | Everything in Plus + priority AI, custom themes, therapist export, early access |

### Product IDs (from RevenueCat)

```
Plus Monthly:  apothy_plus_monthly
Plus Yearly:   apothy_plus_yearly
Pro Monthly:   apothy_pro_monthly
Pro Yearly:    apothy_pro_yearly
```

### Entitlement IDs (from RevenueCat)

```
Plus: "plus"
Pro:  "pro"
```

---

## Architecture

### Data Flow

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Mobile    │         │  RevenueCat  │         │   Backend   │
│     App     │ ──────> │   (Stores)   │ ──────> │   Server    │
└─────────────┘         └──────────────┘         └─────────────┘
      │                                                  │
      │                                                  │
      │            GET /user/subscription                │
      └─────────────────────────────────────────────────┘
```

1. **User purchases subscription** → Mobile app calls RevenueCat SDK
2. **RevenueCat processes payment** → App Store/Play Store handles transaction
3. **RevenueCat sends webhook** → Backend receives subscription event
4. **Backend updates database** → User record updated with subscription info
5. **App queries backend** → Gets latest subscription status

---

## Database Schema

### Update `users` Table

Add the following columns to your existing `users` table:

```sql
-- PostgreSQL / MySQL / SQLite compatible
ALTER TABLE users
ADD COLUMN subscription_tier VARCHAR(20) NOT NULL DEFAULT 'free',
ADD COLUMN subscription_expires_at TIMESTAMP NULL,
ADD COLUMN is_subscription_active BOOLEAN NOT NULL DEFAULT TRUE,
ADD COLUMN subscription_product_id VARCHAR(100) NULL,
ADD COLUMN subscription_original_purchase_date TIMESTAMP NULL,
ADD COLUMN subscription_will_renew BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN subscription_revenue_cat_id VARCHAR(255) NULL,
ADD COLUMN subscription_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- Create index for faster subscription queries
CREATE INDEX idx_users_subscription_tier ON users(subscription_tier);
CREATE INDEX idx_users_subscription_active ON users(is_subscription_active);
CREATE INDEX idx_users_revenue_cat_id ON users(subscription_revenue_cat_id);
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `subscription_tier` | VARCHAR(20) | Enum: 'free', 'plus', 'pro' |
| `subscription_expires_at` | TIMESTAMP | When subscription expires (NULL for free tier) |
| `is_subscription_active` | BOOLEAN | Current active status (handles grace periods, trials) |
| `subscription_product_id` | VARCHAR(100) | Product identifier (e.g., 'apothy_plus_monthly') |
| `subscription_original_purchase_date` | TIMESTAMP | First purchase date for this subscription |
| `subscription_will_renew` | BOOLEAN | Auto-renewal status |
| `subscription_revenue_cat_id` | VARCHAR(255) | RevenueCat user ID for matching webhooks |
| `subscription_updated_at` | TIMESTAMP | Last time subscription was updated |

### Optional: Create `subscription_events` Table for Audit Trail

```sql
CREATE TABLE subscription_events (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    event_type VARCHAR(50) NOT NULL,
    revenue_cat_event_id VARCHAR(255) NOT NULL UNIQUE,
    previous_tier VARCHAR(20),
    new_tier VARCHAR(20) NOT NULL,
    product_id VARCHAR(100),
    expires_at TIMESTAMP,
    will_renew BOOLEAN,
    event_data JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subscription_events_user_id ON subscription_events(user_id);
CREATE INDEX idx_subscription_events_event_type ON subscription_events(event_type);
CREATE INDEX idx_subscription_events_created_at ON subscription_events(created_at);
```

---

## RevenueCat Webhook Handler

### Endpoint Configuration

**URL**: `https://your-api.com/webhooks/revenuecat`
**Method**: `POST`
**Content-Type**: `application/json`

### Webhook Security

RevenueCat sends a custom header for verification:

```
X-RevenueCat-Signature: <signature>
```

**Important**: Verify webhook authenticity by checking this signature against your RevenueCat webhook secret.

### Event Types to Handle

| Event Type | Description | Action Required |
|------------|-------------|-----------------|
| `INITIAL_PURCHASE` | User purchased for first time | Upgrade tier, set active=true |
| `RENEWAL` | Subscription renewed | Update expires_at, set active=true |
| `CANCELLATION` | User cancelled (still active until expiry) | Set will_renew=false, keep active=true |
| `EXPIRATION` | Subscription expired | Set tier=free, active=false |
| `BILLING_ISSUE` | Payment failed, entering grace period | Keep active=true (grace period) |
| `PRODUCT_CHANGE` | User upgraded/downgraded | Update tier and product_id |
| `NON_RENEWING_PURCHASE` | One-time purchase (if supported) | Grant access until expiry |

### Webhook Payload Example

```json
{
  "event": {
    "type": "INITIAL_PURCHASE",
    "id": "unique-event-id",
    "app_user_id": "user@example.com",
    "original_app_user_id": "user@example.com",
    "product_id": "apothy_plus_monthly",
    "entitlement_ids": ["plus"],
    "period_type": "NORMAL",
    "purchased_at_ms": 1702915200000,
    "expiration_at_ms": 1705593600000,
    "store": "APP_STORE",
    "environment": "PRODUCTION",
    "presented_offering_id": "default",
    "transaction_id": "1234567890",
    "original_transaction_id": "1234567890",
    "is_trial_conversion": false,
    "price": 9.99,
    "currency": "USD",
    "subscriber_attributes": {
      "email": {
        "value": "user@example.com",
        "updated_at_ms": 1702915200000
      }
    }
  }
}
```

### Implementation Example (Node.js/Express)

```javascript
const express = require('express');
const crypto = require('crypto');

app.post('/webhooks/revenuecat', async (req, res) => {
  try {
    // 1. Verify webhook signature
    const signature = req.headers['x-revenuecat-signature'];
    if (!verifyWebhookSignature(req.body, signature)) {
      return res.status(401).json({ error: 'Invalid signature' });
    }

    const { event } = req.body;

    // 2. Find user by app_user_id (email or user ID)
    const user = await findUserByRevenueCatId(event.app_user_id);
    if (!user) {
      console.error(`User not found: ${event.app_user_id}`);
      return res.status(404).json({ error: 'User not found' });
    }

    // 3. Parse subscription tier from entitlements
    const tier = parseSubscriptionTier(event.entitlement_ids);

    // 4. Update user subscription based on event type
    switch (event.type) {
      case 'INITIAL_PURCHASE':
      case 'RENEWAL':
        await updateUserSubscription(user.id, {
          tier,
          expiresAt: new Date(event.expiration_at_ms),
          isActive: true,
          productId: event.product_id,
          originalPurchaseDate: new Date(event.purchased_at_ms),
          willRenew: true,
          revenueCatId: event.app_user_id,
        });
        break;

      case 'CANCELLATION':
        await updateUserSubscription(user.id, {
          willRenew: false,
          // Keep tier and active status until expiration
        });
        break;

      case 'EXPIRATION':
        await updateUserSubscription(user.id, {
          tier: 'free',
          isActive: false,
          willRenew: false,
        });
        break;

      case 'BILLING_ISSUE':
        // Keep active during grace period
        await updateUserSubscription(user.id, {
          isActive: true, // Grace period
          willRenew: false,
        });
        break;

      case 'PRODUCT_CHANGE':
        await updateUserSubscription(user.id, {
          tier,
          productId: event.product_id,
          expiresAt: new Date(event.expiration_at_ms),
        });
        break;

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    // 5. Log event for audit trail (optional)
    await logSubscriptionEvent(user.id, event);

    // 6. Acknowledge receipt
    res.status(200).json({ received: true });

  } catch (error) {
    console.error('Webhook processing error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

function parseSubscriptionTier(entitlementIds) {
  if (!entitlementIds || entitlementIds.length === 0) {
    return 'free';
  }

  // Pro takes precedence
  if (entitlementIds.includes('pro')) {
    return 'pro';
  }

  if (entitlementIds.includes('plus')) {
    return 'plus';
  }

  return 'free';
}

function verifyWebhookSignature(payload, signature) {
  const webhookSecret = process.env.REVENUECAT_WEBHOOK_SECRET;

  const hmac = crypto.createHmac('sha256', webhookSecret);
  hmac.update(JSON.stringify(payload));
  const expectedSignature = hmac.digest('hex');

  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expectedSignature)
  );
}
```

### Implementation Example (Python/FastAPI)

```python
from fastapi import FastAPI, Request, HTTPException, Header
from datetime import datetime
import hmac
import hashlib
import json

app = FastAPI()

@app.post("/webhooks/revenuecat")
async def revenuecat_webhook(
    request: Request,
    x_revenuecat_signature: str = Header(None)
):
    try:
        # 1. Verify webhook signature
        body = await request.json()
        if not verify_webhook_signature(body, x_revenuecat_signature):
            raise HTTPException(status_code=401, detail="Invalid signature")

        event = body.get("event", {})

        # 2. Find user
        user = await find_user_by_revenue_cat_id(event.get("app_user_id"))
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        # 3. Parse tier
        tier = parse_subscription_tier(event.get("entitlement_ids", []))

        # 4. Update subscription based on event type
        event_type = event.get("type")

        if event_type in ["INITIAL_PURCHASE", "RENEWAL"]:
            await update_user_subscription(
                user_id=user.id,
                tier=tier,
                expires_at=datetime.fromtimestamp(event["expiration_at_ms"] / 1000),
                is_active=True,
                product_id=event["product_id"],
                original_purchase_date=datetime.fromtimestamp(event["purchased_at_ms"] / 1000),
                will_renew=True,
                revenue_cat_id=event["app_user_id"]
            )

        elif event_type == "CANCELLATION":
            await update_user_subscription(
                user_id=user.id,
                will_renew=False
            )

        elif event_type == "EXPIRATION":
            await update_user_subscription(
                user_id=user.id,
                tier="free",
                is_active=False,
                will_renew=False
            )

        elif event_type == "BILLING_ISSUE":
            await update_user_subscription(
                user_id=user.id,
                is_active=True,  # Grace period
                will_renew=False
            )

        elif event_type == "PRODUCT_CHANGE":
            await update_user_subscription(
                user_id=user.id,
                tier=tier,
                product_id=event["product_id"],
                expires_at=datetime.fromtimestamp(event["expiration_at_ms"] / 1000)
            )

        # 5. Log event (optional)
        await log_subscription_event(user.id, event)

        return {"received": True}

    except Exception as e:
        print(f"Webhook error: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")

def verify_webhook_signature(payload: dict, signature: str) -> bool:
    webhook_secret = os.getenv("REVENUECAT_WEBHOOK_SECRET")

    expected_signature = hmac.new(
        webhook_secret.encode(),
        json.dumps(payload, separators=(',', ':')).encode(),
        hashlib.sha256
    ).hexdigest()

    return hmac.compare_digest(signature, expected_signature)

def parse_subscription_tier(entitlement_ids: list) -> str:
    if not entitlement_ids:
        return "free"

    if "pro" in entitlement_ids:
        return "pro"

    if "plus" in entitlement_ids:
        return "plus"

    return "free"
```

---

## API Endpoints

### 1. Get Current User Subscription

**Endpoint**: `GET /user`
**Authentication**: Required (Bearer token)

**Response** (update existing /user endpoint to include subscription fields):

```json
{
  "id": 123,
  "email": "user@example.com",
  "display_name": "John Doe",
  "photo_url": "https://...",
  "provider": "google",
  "created_at": "2024-01-01T00:00:00Z",
  "last_login_at": "2024-12-12T10:00:00Z",
  "subscription_tier": "plus",
  "subscription_expires_at": "2025-01-12T10:00:00Z",
  "is_subscription_active": true
}
```

### 2. Manual Subscription Sync (Optional)

**Endpoint**: `POST /user/subscription/sync`
**Authentication**: Required (Bearer token)

**Description**: Forces a refresh of subscription status from RevenueCat (useful for debugging)

**Request Body**: None

**Response**:

```json
{
  "subscription_tier": "plus",
  "subscription_expires_at": "2025-01-12T10:00:00Z",
  "is_subscription_active": true,
  "synced_at": "2024-12-12T12:00:00Z"
}
```

**Implementation Note**: This endpoint should call RevenueCat's REST API to verify current status:

```
GET https://api.revenuecat.com/v1/subscribers/{app_user_id}
Authorization: Bearer {REVENUECAT_API_KEY}
```

### 3. Get Subscription Details (Optional - for Settings screen)

**Endpoint**: `GET /user/subscription`
**Authentication**: Required (Bearer token)

**Response**:

```json
{
  "tier": "plus",
  "status": "active",
  "expires_at": "2025-01-12T10:00:00Z",
  "will_renew": true,
  "product_id": "apothy_plus_monthly",
  "original_purchase_date": "2024-12-12T10:00:00Z",
  "days_until_expiration": 31
}
```

---

## Security Considerations

### 1. Webhook Signature Verification

**CRITICAL**: Always verify the `X-RevenueCat-Signature` header to prevent spoofed webhook attacks.

```javascript
// Store this securely in environment variables
const WEBHOOK_SECRET = process.env.REVENUECAT_WEBHOOK_SECRET;

function verifySignature(payload, signature) {
  const hmac = crypto.createHmac('sha256', WEBHOOK_SECRET);
  hmac.update(JSON.stringify(payload));
  const expected = hmac.digest('hex');
  return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected));
}
```

### 2. Idempotency

RevenueCat may send duplicate webhook events. Implement idempotency using the `event.id`:

```sql
-- Check if event already processed
SELECT id FROM subscription_events
WHERE revenue_cat_event_id = :event_id;

-- If found, return 200 without processing
-- If not found, process and insert
```

### 3. User Matching

Match webhooks to users using the `app_user_id` field. This should be set when initializing RevenueCat in the mobile app:

```dart
// In Flutter app (already implemented in mobile app)
await Purchases.logIn(user.email); // or user.id
```

Ensure your backend can look up users by this identifier.

### 4. Rate Limiting

Implement rate limiting on webhook endpoint to prevent abuse:

```javascript
// Express example with express-rate-limit
const rateLimit = require('express-rate-limit');

const webhookLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 1000, // limit each IP to 1000 requests per windowMs
  message: 'Too many webhook requests'
});

app.post('/webhooks/revenuecat', webhookLimiter, handleWebhook);
```

### 5. Environment Separation

Use separate RevenueCat projects for development and production:

- **Production**: Real transactions
- **Sandbox**: Testing with StoreKit/Play Store test accounts

Configure different webhook URLs for each environment.

---

## Testing Strategy

### 1. Webhook Testing

Use RevenueCat's webhook testing tool in the dashboard:

1. Go to RevenueCat Dashboard → Project Settings → Integrations → Webhooks
2. Click "Send Test"
3. Select event type (e.g., INITIAL_PURCHASE)
4. Verify your endpoint receives and processes correctly

### 2. End-to-End Testing

**Sandbox Testing Flow**:

1. Configure iOS/Android sandbox test account
2. Make a test purchase in the app
3. Verify webhook received by backend
4. Verify database updated correctly
5. Query `/user` endpoint - confirm subscription fields present
6. Test expiration: RevenueCat allows setting short expiration times for testing

### 3. Edge Cases to Test

| Scenario | Expected Behavior |
|----------|-------------------|
| **Duplicate webhook** | Idempotency: No duplicate updates |
| **Invalid signature** | 401 Unauthorized response |
| **User not found** | 404 Not Found, log error |
| **Malformed payload** | 400 Bad Request |
| **Upgrade (Plus → Pro)** | Tier updated, new expires_at |
| **Downgrade (Pro → Plus)** | Tier updated at next billing cycle |
| **Cancellation** | will_renew=false, tier unchanged until expiry |
| **Expiration** | tier=free, is_active=false |
| **Payment failure** | Grace period: is_active=true, will_renew=false |

### 4. Load Testing

Test webhook endpoint with concurrent requests:

```bash
# Using Apache Bench
ab -n 1000 -c 10 -p webhook_payload.json \
   -T application/json \
   https://your-api.com/webhooks/revenuecat
```

Expected performance: < 200ms response time for 95th percentile

---

## Deployment Checklist

### Pre-Deployment

- [ ] Database migrations applied (subscription columns added)
- [ ] Indexes created on subscription fields
- [ ] Environment variables configured:
  - [ ] `REVENUECAT_WEBHOOK_SECRET`
  - [ ] `REVENUECAT_API_KEY` (for manual sync)
- [ ] Webhook endpoint deployed and accessible
- [ ] SSL/TLS certificate valid
- [ ] Rate limiting configured
- [ ] Monitoring/alerting set up for webhook failures

### RevenueCat Dashboard Configuration

- [ ] Create RevenueCat project
- [ ] Add App Store Connect integration (iOS)
- [ ] Add Google Play Console integration (Android)
- [ ] Create Products:
  - [ ] apothy_plus_monthly → Plus Monthly subscription
  - [ ] apothy_plus_yearly → Plus Yearly subscription
  - [ ] apothy_pro_monthly → Pro Monthly subscription
  - [ ] apothy_pro_yearly → Pro Yearly subscription
- [ ] Create Entitlements:
  - [ ] "plus" entitlement → Link to Plus products
  - [ ] "pro" entitlement → Link to Pro products
- [ ] Create Offerings (organize products for display)
- [ ] Configure Webhook:
  - [ ] URL: `https://your-api.com/webhooks/revenuecat`
  - [ ] Authorization: None (use signature verification)
  - [ ] Events: Select all relevant events
  - [ ] Test webhook with "Send Test" button

### Post-Deployment Verification

- [ ] Send test webhook → Verify received and processed
- [ ] Make test purchase (sandbox) → Verify:
  - [ ] Webhook received
  - [ ] Database updated
  - [ ] `/user` endpoint returns correct subscription
- [ ] Test cancellation flow
- [ ] Test expiration flow
- [ ] Monitor error logs for 24 hours
- [ ] Verify mobile app receives subscription status correctly

### Monitoring Setup

Set up alerts for:

- Webhook endpoint failures (5xx errors)
- Webhook signature verification failures
- Processing time > 1 second
- Database update failures
- Unhandled event types

**Recommended Monitoring Tools**:
- Sentry/Rollbar for error tracking
- Datadog/New Relic for performance monitoring
- CloudWatch/Stackdriver for logs

---

## Common Issues & Troubleshooting

### Issue: Webhook not receiving events

**Causes**:
- Incorrect webhook URL in RevenueCat dashboard
- SSL certificate issues
- Firewall blocking RevenueCat IPs
- Endpoint returning non-200 status code

**Solution**:
1. Verify URL is correct and publicly accessible
2. Check SSL certificate is valid
3. Test with RevenueCat's "Send Test" button
4. Check server logs for incoming requests

### Issue: User not found in webhook

**Causes**:
- `app_user_id` not matching database identifier
- User deleted but subscription still active

**Solution**:
1. Ensure RevenueCat `app_user_id` matches user email or ID in database
2. Log unmatched webhooks for investigation
3. Implement fallback: create user if doesn't exist (if applicable)

### Issue: Subscription not updating in app

**Causes**:
- Caching on mobile app side
- Backend not returning updated fields
- Mobile app not refreshing subscription provider

**Solution**:
1. Mobile app calls `ref.read(subscriptionProvider.notifier).refresh()` after purchase
2. Verify `/user` endpoint includes subscription fields
3. Check cache TTL on mobile app (currently 1 hour)

### Issue: Double billing or incorrect tier

**Causes**:
- Race condition with multiple webhook events
- Incorrect tier parsing logic
- Product change not handled correctly

**Solution**:
1. Implement proper idempotency with event.id
2. Use database transactions when updating subscription
3. Log all tier changes for audit

---

## Additional Resources

- **RevenueCat Documentation**: https://www.revenuecat.com/docs
- **RevenueCat Webhook Reference**: https://www.revenuecat.com/docs/webhooks
- **RevenueCat REST API**: https://www.revenuecat.com/docs/api-v1
- **App Store Server Notifications**: https://developer.apple.com/documentation/appstoreservernotifications
- **Google Play Billing**: https://developer.android.com/google/play/billing

---

## Support

For questions or issues:

1. Check RevenueCat dashboard for webhook delivery status
2. Review server logs for error messages
3. Test webhooks manually using RevenueCat's testing tool
4. Contact RevenueCat support if issues with their service
5. Review this guide's troubleshooting section

---

**Document Version**: 1.0
**Last Updated**: December 12, 2024
**Flutter App Commit**: 3bb9037
