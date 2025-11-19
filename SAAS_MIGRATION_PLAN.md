# SaaS Migration Plan: voiceFX AI → SaaS Product

## Executive Summary

This document outlines the plan to transform voiceFX AI from an open-source self-hosted platform into a fully-featured SaaS product using Supabase as the database backend. The migration will enable businesses to build and deploy AI voice agents without infrastructure management.

---

## Phase 1: Database Migration to Supabase

### 1.1 Supabase Setup
- [ ] Create Supabase project
- [ ] Configure connection pooling (PgBouncer)
- [ ] Set up database connection string format: `postgresql+asyncpg://postgres:[password]@[host]:5432/postgres?sslmode=require`

### 1.2 Schema Migration
- [ ] Export current PostgreSQL schema
- [ ] Create Supabase migration scripts
- [ ] Migrate all tables:
  - `users` → Supabase `auth.users` + custom `profiles` table
  - `organizations` → Keep as-is with RLS
  - `workflows`, `workflow_runs`, `campaigns`, etc. → Migrate as-is
- [ ] Set up Row-Level Security (RLS) policies

### 1.3 Code Changes
**Files to modify:**
- `api/db/database.py` - Update connection string handling
- `api/db/base_client.py` - Add Supabase connection pooling
- `api/constants.py` - Add Supabase-specific config
- All client files - Ensure RLS context is set

**New files:**
- `api/db/supabase_client.py` - Supabase-specific utilities
- `api/db/rls_context.py` - Row-Level Security context management

### 1.4 Row-Level Security (RLS) Policies

```sql
-- Example RLS policies needed:

-- Organizations: Users can only see their own organizations
CREATE POLICY "Users can view own organizations"
  ON organizations FOR SELECT
  USING (id IN (
    SELECT organization_id FROM organization_users 
    WHERE user_id = auth.uid()::text
  ));

-- Workflows: Organization-scoped access
CREATE POLICY "Users can view organization workflows"
  ON workflows FOR SELECT
  USING (organization_id IN (
    SELECT organization_id FROM organization_users 
    WHERE user_id = auth.uid()::text
  ));

-- Similar policies for all tables
```

---

## Phase 2: Authentication System

### 2.1 Replace Stack Auth with Supabase Auth
- [ ] Remove Stack Auth dependency
- [ ] Install `@supabase/supabase-js` (frontend)
- [ ] Install `supabase` Python client (backend)
- [ ] Update `api/services/auth/depends.py`:
  - Replace `stackauth.get_user()` with Supabase Auth
  - Use JWT verification from Supabase
  - Map Supabase user to local UserModel

### 2.2 Frontend Auth Integration
- [ ] Update `ui/src/lib/auth.tsx` - Replace Stack Auth with Supabase
- [ ] Create Supabase client singleton
- [ ] Update login/signup flows
- [ ] Add email verification flow
- [ ] Add password reset flow

### 2.3 User Management
- [ ] Create `profiles` table linked to `auth.users`
- [ ] Sync user creation: Supabase Auth → local `users` table
- [ ] Handle user deletion (cascade or soft delete)
- [ ] Add user settings page

**New database table:**
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Phase 3: Multi-Tenancy & Security

### 3.1 Organization Isolation
- [ ] Ensure all queries filter by `organization_id`
- [ ] Add RLS policies for all tables
- [ ] Implement organization context middleware
- [ ] Add organization switching UI

### 3.2 Team Management
- [ ] Add team member invitation system
- [ ] Role-based access control (Owner, Admin, Member, Viewer)
- [ ] Permission system for workflows/campaigns
- [ ] Team activity logs

**New table:**
```sql
CREATE TABLE organization_members (
  id SERIAL PRIMARY KEY,
  organization_id INTEGER REFERENCES organizations(id),
  user_id UUID REFERENCES auth.users(id),
  role TEXT DEFAULT 'member', -- owner, admin, member, viewer
  invited_by UUID REFERENCES auth.users(id),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(organization_id, user_id)
);
```

---

## Phase 4: Billing & Subscriptions

### 4.1 Stripe Integration
- [ ] Install Stripe Python SDK
- [ ] Set up Stripe webhook endpoint
- [ ] Create subscription management service
- [ ] Add Stripe customer creation on signup

**New tables:**
```sql
CREATE TABLE subscriptions (
  id SERIAL PRIMARY KEY,
  organization_id INTEGER REFERENCES organizations(id),
  stripe_customer_id TEXT UNIQUE,
  stripe_subscription_id TEXT UNIQUE,
  status TEXT, -- active, canceled, past_due, etc.
  plan_id TEXT, -- starter, pro, enterprise
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  cancel_at_period_end BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE subscription_plans (
  id TEXT PRIMARY KEY, -- starter, pro, enterprise
  name TEXT NOT NULL,
  price_monthly INTEGER, -- in cents
  price_annual INTEGER,
  features JSONB, -- { "max_workflows": 10, "max_calls_per_month": 1000 }
  limits JSONB
);
```

### 4.2 Pricing Tiers

**Starter Plan ($29/month)**
- 5 workflows
- 500 calls/month
- Basic analytics
- Email support

**Pro Plan ($99/month)**
- Unlimited workflows
- 5,000 calls/month
- Advanced analytics
- Priority support
- API access

**Enterprise Plan (Custom)**
- Unlimited everything
- Dedicated support
- Custom integrations
- SLA guarantees

### 4.3 Usage Tracking
- [ ] Track calls per organization
- [ ] Track storage usage
- [ ] Track API requests
- [ ] Implement usage limits enforcement
- [ ] Add usage dashboard

**Enhance existing `organization_usage_cycles` table:**
- Add `subscription_id` foreign key
- Track against plan limits
- Alert when approaching limits

---

## Phase 5: SaaS Dashboard & Analytics

### 5.1 Dashboard Features
- [ ] Overview metrics (calls today, active workflows, etc.)
- [ ] Usage charts (calls over time, cost breakdown)
- [ ] Recent activity feed
- [ ] Quick actions (create workflow, start campaign)

### 5.2 Analytics
- [ ] Call analytics (duration, success rate, cost)
- [ ] Workflow performance metrics
- [ ] Campaign analytics
- [ ] Export reports (CSV, PDF)

### 5.3 Billing Dashboard
- [ ] Current subscription status
- [ ] Usage vs. plan limits
- [ ] Billing history
- [ ] Invoice downloads
- [ ] Payment method management

---

## Phase 6: Onboarding & User Experience

### 6.1 Onboarding Flow
- [ ] Welcome screen
- [ ] Product tour
- [ ] First workflow creation wizard
- [ ] Sample templates
- [ ] Integration setup guide

### 6.2 Documentation
- [ ] In-app help tooltips
- [ ] Video tutorials
- [ ] API documentation
- [ ] Best practices guide

### 6.3 Support System
- [ ] Help center (knowledge base)
- [ ] Support ticket system
- [ ] Live chat integration (Intercom/Crisp)
- [ ] Community forum

---

## Phase 7: API Access for Customers

### 7.1 Public API
- [ ] RESTful API design
- [ ] API key authentication
- [ ] Rate limiting per API key
- [ ] API documentation (OpenAPI/Swagger)

**Endpoints:**
```
POST /api/v1/workflows - Create workflow
GET /api/v1/workflows - List workflows
POST /api/v1/workflows/{id}/runs - Execute workflow
GET /api/v1/campaigns - List campaigns
POST /api/v1/campaigns - Create campaign
```

### 7.2 Webhooks
- [ ] Webhook system for events
- [ ] Event types: call.completed, workflow.finished, etc.
- [ ] Webhook management UI
- [ ] Retry logic for failed webhooks

---

## Phase 8: Infrastructure & Deployment

### 8.1 Hosting Setup
- [ ] **Frontend**: Vercel (Next.js optimized)
- [ ] **Backend**: Railway or Render (FastAPI)
- [ ] **Database**: Supabase (managed PostgreSQL)
- [ ] **Storage**: Supabase Storage or AWS S3
- [ ] **Redis**: Upstash (serverless Redis)
- [ ] **CDN**: Cloudflare (for static assets)

### 8.2 Environment Configuration
```bash
# Production environment variables
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=xxx
SUPABASE_SERVICE_ROLE_KEY=xxx
DATABASE_URL=postgresql+asyncpg://...
STRIPE_SECRET_KEY=sk_live_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
REDIS_URL=redis://...
SENTRY_DSN=xxx
```

### 8.3 CI/CD Pipeline
- [ ] GitHub Actions for deployment
- [ ] Automated testing
- [ ] Database migrations (Alembic)
- [ ] Staging environment
- [ ] Production deployment workflow

### 8.4 Monitoring & Observability
- [ ] Sentry for error tracking
- [ ] Logging (Logtail/Papertrail)
- [ ] Uptime monitoring (UptimeRobot)
- [ ] Performance monitoring (New Relic/Datadog)
- [ ] Cost tracking (CloudHealth)

---

## Phase 9: Additional SaaS Features

### 9.1 White-Label Options (Future)
- [ ] Custom branding
- [ ] Custom domain
- [ ] Custom email templates

### 9.2 Advanced Features
- [ ] Workflow templates marketplace
- [ ] AI-powered workflow suggestions
- [ ] Voice cloning
- [ ] Multi-language support
- [ ] A/B testing for workflows

### 9.3 Compliance
- [ ] GDPR compliance
- [ ] SOC 2 certification (future)
- [ ] Data encryption at rest
- [ ] Audit logs
- [ ] Data export/deletion tools

---

## Migration Strategy

### Step-by-Step Migration

1. **Week 1-2: Supabase Setup**
   - Create Supabase project
   - Migrate schema
   - Set up RLS policies
   - Test database connectivity

2. **Week 3-4: Auth Migration**
   - Replace Stack Auth with Supabase Auth
   - Update frontend auth flows
   - Test user registration/login

3. **Week 5-6: Multi-tenancy**
   - Implement RLS policies
   - Add team management
   - Test organization isolation

4. **Week 7-8: Billing Integration**
   - Integrate Stripe
   - Create subscription plans
   - Implement usage tracking
   - Build billing dashboard

5. **Week 9-10: Dashboard & Analytics**
   - Build SaaS dashboard
   - Add analytics
   - Create onboarding flow

6. **Week 11-12: API & Infrastructure**
   - Build public API
   - Set up production infrastructure
   - Deploy to staging
   - Load testing

7. **Week 13-14: Testing & Launch**
   - End-to-end testing
   - Security audit
   - Performance optimization
   - Beta testing with select users
   - Public launch

---

## Technical Implementation Details

### Supabase Connection

**Backend (`api/db/supabase_client.py`):**
```python
from supabase import create_client, Client
from api.constants import SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

# For database operations, use asyncpg directly
# Supabase uses standard PostgreSQL, so existing SQLAlchemy code works
```

**Frontend (`ui/src/lib/supabase.ts`):**
```typescript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

### Authentication Middleware

**Backend (`api/services/auth/supabase_auth.py`):**
```python
from supabase import create_client
from fastapi import HTTPException, Header
from api.db import db_client

async def get_user(authorization: str = Header(None)) -> UserModel:
    if not authorization:
        raise HTTPException(401, "Missing authorization")
    
    token = authorization.replace("Bearer ", "")
    
    # Verify JWT with Supabase
    supabase = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)
    user = supabase.auth.get_user(token)
    
    if not user:
        raise HTTPException(401, "Invalid token")
    
    # Get or create local user record
    user_model = await db_client.get_or_create_user_by_provider_id(
        provider_id=user.id
    )
    
    return user_model
```

### Stripe Integration

**New service (`api/services/billing/stripe_service.py`):**
```python
import stripe
from api.db import db_client

stripe.api_key = os.getenv("STRIPE_SECRET_KEY")

async def create_customer(organization_id: int, email: str):
    customer = stripe.Customer.create(email=email)
    await db_client.create_stripe_customer(
        organization_id=organization_id,
        stripe_customer_id=customer.id
    )
    return customer

async def create_subscription(customer_id: str, plan_id: str):
    subscription = stripe.Subscription.create(
        customer=customer_id,
        items=[{"price": PLAN_PRICES[plan_id]}],
    )
    return subscription
```

---

## Risk Mitigation

1. **Data Loss**: 
   - Full database backup before migration
   - Test migration on staging first
   - Rollback plan ready

2. **Downtime**:
   - Use blue-green deployment
   - Migrate during low-traffic hours
   - Have maintenance page ready

3. **Performance**:
   - Load test Supabase connection
   - Monitor query performance
   - Optimize RLS policies

4. **Security**:
   - Security audit before launch
   - Penetration testing
   - Regular security updates

---

## Success Metrics

- **User Acquisition**: 100+ signups in first month
- **Conversion**: 10% free-to-paid conversion
- **Retention**: 80% monthly retention
- **Performance**: <200ms API response time
- **Uptime**: 99.9% availability

---

## Next Steps

1. Review and approve this plan
2. Set up Supabase project
3. Create detailed technical specifications
4. Begin Phase 1 implementation
5. Weekly progress reviews

---

## Questions & Considerations

1. **Pricing**: Should we offer a free tier?
2. **Migration**: Do we need to support existing self-hosted users?
3. **Features**: Which features should be premium-only?
4. **Support**: What support channels to offer?
5. **Compliance**: Which regions to target first?

---

*Last updated: [Date]*
*Version: 1.0*

