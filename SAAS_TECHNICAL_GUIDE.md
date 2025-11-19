# SaaS Technical Implementation Guide

## Quick Start: Supabase Migration

### 1. Supabase Project Setup

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Initialize project (if starting fresh)
supabase init

# Link to existing project
supabase link --project-ref your-project-ref
```

### 2. Database Connection Update

**File: `api/constants.py`**
```python
import os

# Supabase connection
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

# Database URL for Supabase (use connection pooling)
# Format: postgresql+asyncpg://postgres.[project-ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres
DATABASE_URL = os.getenv("DATABASE_URL")  # Supabase connection string

# For direct connection (not recommended for production)
# DATABASE_URL = os.getenv("DATABASE_DIRECT_URL")
```

**File: `api/db/database.py`**
```python
import os
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import NullPool  # Important for Supabase connection pooling

DATABASE_URL = os.environ["DATABASE_URL"]

# Supabase uses connection pooling, so we need to configure accordingly
engine = create_async_engine(
    DATABASE_URL,
    echo=False,  # Set to True for debugging
    poolclass=NullPool,  # Supabase handles pooling
    connect_args={
        "server_settings": {
            "application_name": "voicefx_api",
        }
    }
)

async_session = sessionmaker(engine, expire_on_commit=False)
```

### 3. Supabase Auth Integration

**File: `api/services/auth/supabase_auth.py` (NEW)**
```python
from typing import Optional
from fastapi import HTTPException, Header
from supabase import create_client, Client
from api.constants import SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
from api.db import db_client
from api.db.models import UserModel

# Create Supabase client for auth operations
supabase_auth: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)


async def get_user_from_token(token: str) -> Optional[dict]:
    """Verify JWT token and get user from Supabase Auth."""
    try:
        # Verify token and get user
        response = supabase_auth.auth.get_user(token)
        if response.user:
            return {
                "id": response.user.id,
                "email": response.user.email,
                "user_metadata": response.user.user_metadata or {}
            }
    except Exception as e:
        print(f"Auth error: {e}")
        return None
    return None


async def get_user(
    authorization: Optional[str] = Header(None)
) -> UserModel:
    """FastAPI dependency to get authenticated user."""
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing authorization header")
    
    # Extract token
    token = authorization.replace("Bearer ", "").strip()
    if not token:
        raise HTTPException(status_code=401, detail="Invalid authorization format")
    
    # Verify token with Supabase
    supabase_user = await get_user_from_token(token)
    if not supabase_user:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    
    # Get or create user in our database
    user_model = await db_client.get_or_create_user_by_provider_id(
        provider_id=supabase_user["id"]
    )
    
    # Update email if changed
    if supabase_user.get("email") and user_model.provider_id == supabase_user["id"]:
        # You might want to store email in a profiles table
        pass
    
    return user_model
```

**Update: `api/services/auth/depends.py`**
```python
# Replace Stack Auth import with Supabase Auth
from api.services.auth.supabase_auth import get_user as get_user_supabase

# Keep the same function name for backward compatibility
get_user = get_user_supabase
```

### 4. Frontend Auth Setup

**File: `ui/src/lib/supabase.ts` (NEW)**
```typescript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  }
})

// Helper to get auth token for API calls
export const getAuthToken = async (): Promise<string | null> => {
  const { data: { session } } = await supabase.auth.getSession()
  return session?.access_token || null
}
```

**File: `ui/src/lib/auth.tsx` (UPDATE)**
```typescript
'use client'

import { createContext, useContext, useEffect, useState } from 'react'
import { User } from '@supabase/supabase-js'
import { supabase } from './supabase'

interface AuthContextType {
  user: User | null
  loading: boolean
  signIn: (email: string, password: string) => Promise<void>
  signUp: (email: string, password: string) => Promise<void>
  signOut: () => Promise<void>
  getToken: () => Promise<string | null>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null)
      setLoading(false)
    })

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setUser(session?.user ?? null)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    if (error) throw error
  }

  const signUp = async (email: string, password: string) => {
    const { error } = await supabase.auth.signUp({
      email,
      password,
    })
    if (error) throw error
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  const getToken = async () => {
    const { data: { session } } = await supabase.auth.getSession()
    return session?.access_token || null
  }

  return (
    <AuthContext.Provider value={{ user, loading, signIn, signUp, signOut, getToken }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}
```

### 5. Row-Level Security (RLS) Setup

**Migration File: `api/alembic/versions/xxx_add_rls_policies.py`**
```python
"""Add RLS policies for multi-tenancy

Revision ID: add_rls_policies
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers
revision = 'add_rls_policies'
down_revision = 'previous_revision'
branch_labels = None
depends_on = None

def upgrade():
    # Enable RLS on all tables
    op.execute("ALTER TABLE organizations ENABLE ROW LEVEL SECURITY")
    op.execute("ALTER TABLE workflows ENABLE ROW LEVEL SECURITY")
    op.execute("ALTER TABLE workflow_runs ENABLE ROW LEVEL SECURITY")
    op.execute("ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY")
    # ... enable for all other tables
    
    # Create helper function to get user's organization IDs
    op.execute("""
        CREATE OR REPLACE FUNCTION get_user_organization_ids(user_uuid UUID)
        RETURNS TABLE(org_id INTEGER) AS $$
        BEGIN
            RETURN QUERY
            SELECT ou.organization_id
            FROM organization_users ou
            WHERE ou.user_id = (
                SELECT id FROM users WHERE provider_id = user_uuid::text
            );
        END;
        $$ LANGUAGE plpgsql SECURITY DEFINER;
    """)
    
    # Organizations policy
    op.execute("""
        CREATE POLICY "users_view_own_organizations"
        ON organizations FOR SELECT
        USING (
            id IN (
                SELECT org_id FROM get_user_organization_ids(auth.uid())
            )
        );
    """)
    
    # Workflows policy
    op.execute("""
        CREATE POLICY "users_view_org_workflows"
        ON workflows FOR SELECT
        USING (
            organization_id IN (
                SELECT org_id FROM get_user_organization_ids(auth.uid())
            )
        );
    """)
    
    # Similar policies for other tables...

def downgrade():
    # Drop all policies
    op.execute("DROP POLICY IF EXISTS users_view_own_organizations ON organizations")
    op.execute("DROP POLICY IF EXISTS users_view_org_workflows ON workflows")
    # ... drop all other policies
    
    # Disable RLS
    op.execute("ALTER TABLE organizations DISABLE ROW LEVEL SECURITY")
    op.execute("ALTER TABLE workflows DISABLE ROW LEVEL SECURITY")
    # ... disable for all tables
```

### 6. Stripe Billing Integration

**File: `api/services/billing/stripe_service.py` (NEW)**
```python
import os
import stripe
from typing import Optional, Dict, Any
from loguru import logger
from api.db import db_client
from api.constants import STRIPE_SECRET_KEY

stripe.api_key = STRIPE_SECRET_KEY

# Plan configurations
PLANS = {
    "starter": {
        "price_id_monthly": os.getenv("STRIPE_PRICE_STARTER_MONTHLY"),
        "price_id_annual": os.getenv("STRIPE_PRICE_STARTER_ANNUAL"),
        "limits": {
            "max_workflows": 5,
            "max_calls_per_month": 500,
            "max_campaigns": 3,
        }
    },
    "pro": {
        "price_id_monthly": os.getenv("STRIPE_PRICE_PRO_MONTHLY"),
        "price_id_annual": os.getenv("STRIPE_PRICE_PRO_ANNUAL"),
        "limits": {
            "max_workflows": -1,  # Unlimited
            "max_calls_per_month": 5000,
            "max_campaigns": -1,
        }
    },
    "enterprise": {
        "price_id_monthly": os.getenv("STRIPE_PRICE_ENTERPRISE_MONTHLY"),
        "price_id_annual": os.getenv("STRIPE_PRICE_ENTERPRISE_ANNUAL"),
        "limits": {
            "max_workflows": -1,
            "max_calls_per_month": -1,
            "max_campaigns": -1,
        }
    }
}


class StripeService:
    @staticmethod
    async def create_customer(organization_id: int, email: str, name: str = None) -> str:
        """Create Stripe customer and link to organization."""
        try:
            customer = stripe.Customer.create(
                email=email,
                name=name,
                metadata={
                    "organization_id": str(organization_id)
                }
            )
            
            # Store in database
            await db_client.update_organization(
                organization_id=organization_id,
                stripe_customer_id=customer.id
            )
            
            logger.info(f"Created Stripe customer {customer.id} for org {organization_id}")
            return customer.id
        except Exception as e:
            logger.error(f"Failed to create Stripe customer: {e}")
            raise
    
    @staticmethod
    async def create_subscription(
        customer_id: str,
        plan_id: str,
        billing_cycle: str = "monthly"  # or "annual"
    ) -> Dict[str, Any]:
        """Create subscription for customer."""
        if plan_id not in PLANS:
            raise ValueError(f"Invalid plan: {plan_id}")
        
        price_id = PLANS[plan_id][f"price_id_{billing_cycle}"]
        
        subscription = stripe.Subscription.create(
            customer=customer_id,
            items=[{"price": price_id}],
            metadata={"plan_id": plan_id}
        )
        
        return {
            "subscription_id": subscription.id,
            "status": subscription.status,
            "current_period_start": subscription.current_period_start,
            "current_period_end": subscription.current_period_end,
        }
    
    @staticmethod
    async def cancel_subscription(subscription_id: str, immediately: bool = False):
        """Cancel subscription."""
        if immediately:
            stripe.Subscription.delete(subscription_id)
        else:
            stripe.Subscription.modify(
                subscription_id,
                cancel_at_period_end=True
            )
    
    @staticmethod
    async def handle_webhook(event: Dict[str, Any]):
        """Handle Stripe webhook events."""
        event_type = event["type"]
        
        if event_type == "customer.subscription.created":
            # Link subscription to organization
            subscription = event["data"]["object"]
            customer_id = subscription["customer"]
            # Update database...
            
        elif event_type == "customer.subscription.updated":
            # Update subscription status
            subscription = event["data"]["object"]
            # Update database...
            
        elif event_type == "customer.subscription.deleted":
            # Handle cancellation
            subscription = event["data"]["object"]
            # Update database...
            
        elif event_type == "invoice.payment_succeeded":
            # Record successful payment
            invoice = event["data"]["object"]
            # Update database...
            
        elif event_type == "invoice.payment_failed":
            # Handle failed payment
            invoice = event["data"]["object"]
            # Notify user, update status...
```

**File: `api/routes/billing.py` (NEW)**
```python
from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel
from api.db.models import UserModel
from api.services.auth.depends import get_user
from api.services.billing.stripe_service import StripeService

router = APIRouter(prefix="/billing")


class CreateCheckoutSessionRequest(BaseModel):
    plan_id: str  # starter, pro, enterprise
    billing_cycle: str = "monthly"  # monthly or annual


@router.post("/create-checkout-session")
async def create_checkout_session(
    request: CreateCheckoutSessionRequest,
    user: UserModel = Depends(get_user)
):
    """Create Stripe checkout session."""
    organization = await db_client.get_organization(user.selected_organization_id)
    
    # Get or create Stripe customer
    if not organization.stripe_customer_id:
        customer_id = await StripeService.create_customer(
            organization_id=organization.id,
            email=user.email  # You'll need to get this from Supabase
        )
    else:
        customer_id = organization.stripe_customer_id
    
    # Create checkout session
    import stripe
    session = stripe.checkout.Session.create(
        customer=customer_id,
        payment_method_types=["card"],
        line_items=[{
            "price": PLANS[request.plan_id][f"price_id_{request.billing_cycle}"],
            "quantity": 1,
        }],
        mode="subscription",
        success_url=f"{FRONTEND_URL}/billing/success?session_id={{CHECKOUT_SESSION_ID}}",
        cancel_url=f"{FRONTEND_URL}/billing/cancel",
        metadata={
            "organization_id": str(organization.id),
            "plan_id": request.plan_id
        }
    )
    
    return {"checkout_url": session.url}


@router.post("/webhook")
async def stripe_webhook(request: Request):
    """Handle Stripe webhook events."""
    payload = await request.body()
    sig_header = request.headers.get("stripe-signature")
    
    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, STRIPE_WEBHOOK_SECRET
        )
    except ValueError:
        raise HTTPException(400, "Invalid payload")
    except stripe.error.SignatureVerificationError:
        raise HTTPException(400, "Invalid signature")
    
    await StripeService.handle_webhook(event)
    
    return {"status": "success"}
```

### 7. Usage Tracking & Limits

**File: `api/services/billing/usage_service.py` (NEW)**
```python
from typing import Dict, Any
from api.db import db_client
from api.services.billing.stripe_service import PLANS

class UsageService:
    @staticmethod
    async def check_limits(organization_id: int) -> Dict[str, Any]:
        """Check if organization is within plan limits."""
        organization = await db_client.get_organization(organization_id)
        subscription = await db_client.get_subscription(organization_id)
        
        if not subscription or subscription.status != "active":
            # Free tier limits
            limits = {
                "max_workflows": 1,
                "max_calls_per_month": 50,
                "max_campaigns": 0,
            }
        else:
            plan_id = subscription.plan_id
            limits = PLANS[plan_id]["limits"]
        
        # Get current usage
        workflow_count = await db_client.get_workflow_count(organization_id)
        calls_this_month = await db_client.get_calls_this_month(organization_id)
        campaign_count = await db_client.get_campaign_count(organization_id)
        
        return {
            "limits": limits,
            "usage": {
                "workflows": workflow_count,
                "calls_this_month": calls_this_month,
                "campaigns": campaign_count,
            },
            "within_limits": {
                "workflows": limits["max_workflows"] == -1 or workflow_count < limits["max_workflows"],
                "calls": limits["max_calls_per_month"] == -1 or calls_this_month < limits["max_calls_per_month"],
                "campaigns": limits["max_campaigns"] == -1 or campaign_count < limits["max_campaigns"],
            }
        }
    
    @staticmethod
    async def enforce_limits(organization_id: int, action: str):
        """Enforce limits before allowing action."""
        usage = await UsageService.check_limits(organization_id)
        
        if action == "create_workflow":
            if not usage["within_limits"]["workflows"]:
                raise HTTPException(403, "Workflow limit reached. Upgrade your plan.")
        
        elif action == "make_call":
            if not usage["within_limits"]["calls"]:
                raise HTTPException(403, "Call limit reached for this month. Upgrade your plan.")
        
        elif action == "create_campaign":
            if not usage["within_limits"]["campaigns"]:
                raise HTTPException(403, "Campaign limit reached. Upgrade your plan.")
```

### 8. Environment Variables

**File: `.env.example` (UPDATE)**
```bash
# Supabase
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=xxx
SUPABASE_SERVICE_ROLE_KEY=xxx
DATABASE_URL=postgresql+asyncpg://postgres.xxx:xxx@aws-0-us-east-1.pooler.supabase.com:6543/postgres

# Stripe
STRIPE_SECRET_KEY=sk_live_xxx
STRIPE_PUBLISHABLE_KEY=pk_live_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
STRIPE_PRICE_STARTER_MONTHLY=price_xxx
STRIPE_PRICE_STARTER_ANNUAL=price_xxx
STRIPE_PRICE_PRO_MONTHLY=price_xxx
STRIPE_PRICE_PRO_ANNUAL=price_xxx

# Redis
REDIS_URL=redis://...

# Storage
ENABLE_AWS_S3=true
S3_BUCKET=voicefx-prod
S3_REGION=us-east-1

# Frontend URL
FRONTEND_URL=https://app.voicefx.com
```

### 9. Package Dependencies

**File: `api/requirements.txt` (UPDATE)**
```txt
# Add these
supabase==2.0.0
stripe==7.0.0
```

**File: `ui/package.json` (UPDATE)**
```json
{
  "dependencies": {
    "@supabase/supabase-js": "^2.39.0",
    "@stripe/stripe-js": "^2.0.0"
  }
}
```

---

## Next Steps

1. Set up Supabase project
2. Run database migrations
3. Update authentication code
4. Test thoroughly
5. Deploy to staging
6. Launch!

