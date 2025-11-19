# Development Environment Setup

## Prerequisites

- Python 3.12+
- Node.js 20+
- Docker & Docker Compose
- Git
- Cursor IDE (recommended) or VS Code

---

## Quick Start

### 1. Clone Repository

```bash
git clone <repository-url>
cd voiceAI-agents
```

### 2. Backend Setup

```bash
cd api

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration
```

### 3. Frontend Setup

```bash
cd ui

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env.local
# Edit .env.local with your configuration
```

### 4. Database Setup

**Option A: Local PostgreSQL (Current)**
```bash
# Using Docker Compose
docker-compose up -d postgres redis minio

# Run migrations
cd api
alembic upgrade head
```

**Option B: Supabase (After Phase 3)**
- Create Supabase project
- Get connection string
- Update `DATABASE_URL` in `.env`
- Run migrations in Supabase SQL editor

### 5. Run Development Servers

**Terminal 1 - Backend:**
```bash
cd api
source venv/bin/activate
uvicorn app:app --reload --port 8000
```

**Terminal 2 - Frontend:**
```bash
cd ui
npm run dev
```

**Terminal 3 - Services (if using Docker):**
```bash
docker-compose up
```

### 6. Access Application

- Frontend: http://localhost:3010
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/api/v1/openapi.json

---

## Environment Variables

### Backend (`api/.env`)

```bash
# Database
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/postgres

# Redis
REDIS_URL=redis://localhost:6379

# Storage (MinIO or S3)
ENABLE_AWS_S3=false
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET=voice-audio

# Supabase (After Phase 3)
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=xxx
SUPABASE_SERVICE_ROLE_KEY=xxx

# Other
ENVIRONMENT=local
LOG_LEVEL=INFO
ENABLE_TELEMETRY=false
```

### Frontend (`ui/.env.local`)

```bash
# Backend URL
NEXT_PUBLIC_BACKEND_URL=http://localhost:8000

# Supabase (After Phase 3)
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=xxx

# Other
NODE_ENV=development
```

---

## Common Issues

### Database Connection Error
- Check PostgreSQL is running: `docker ps`
- Verify `DATABASE_URL` is correct
- Check database exists

### Port Already in Use
- Backend: Change port in `uvicorn` command
- Frontend: Change port in `package.json` or use `-p 3011`

### Module Not Found
- Backend: `pip install -r requirements.txt`
- Frontend: `npm install`

### Migration Errors
```bash
cd api
alembic upgrade head
# If errors, check database connection
```

---

## Testing

### Backend Tests
```bash
cd api
pytest tests/
```

### Frontend Tests
```bash
cd ui
npm run test
```

### Linting
```bash
# Backend
cd api
ruff check .
black .

# Frontend
cd ui
npm run lint
```

---

## Git Workflow

### Before Starting Work
```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

### Daily Workflow
```bash
# Pull latest changes
git checkout develop
git pull origin develop

# Work on your feature
git checkout feature/your-feature-name
# ... make changes ...
git add .
git commit -m "feat: your change"
git push origin feature/your-feature-name
```

---

## Troubleshooting

### Reset Everything
```bash
# Stop all services
docker-compose down

# Remove volumes (careful - deletes data)
docker-compose down -v

# Rebuild
docker-compose up --build
```

### Clear Frontend Cache
```bash
cd ui
rm -rf .next
npm run dev
```

### Reset Database
```bash
cd api
alembic downgrade base
alembic upgrade head
```

---

*Last Updated: [Date]*

