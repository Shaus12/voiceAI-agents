# How to Start the App

## Step 1: Start Services (PostgreSQL, Redis, MinIO)
```bash
docker-compose up -d postgres redis minio
```

## Step 2: Start Backend
```bash
cd /Users/user/Desktop/Voice_agents/voiceAI-agents
source api/venv/bin/activate
export DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5434/postgres
export REDIS_URL=redis://:redissecret@localhost:6379
export DEPLOYMENT_MODE=oss
uvicorn api.app:app --reload --port 8000
```

## Step 3: Start Frontend (new terminal)
```bash
cd /Users/user/Desktop/Voice_agents/voiceAI-agents/ui
npm run dev
```

## Step 4: Open Website
Go to: http://localhost:3010

---

That's it! Test the features and see what works.

