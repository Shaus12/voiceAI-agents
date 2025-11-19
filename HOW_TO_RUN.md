# How to Run and Test

## Quick Start

### 1. Start services (PostgreSQL, Redis, MinIO)
```bash
docker-compose up -d postgres redis minio
```

### 2. Run backend
```bash
cd api
uvicorn app:app --reload --port 8000
```

### 3. Run frontend (new terminal)
```bash
cd ui
npm run dev
```

### 4. Open website
Go to: http://localhost:3010

---

## Test the Functions

Just click around and test:
- Login/Register
- Create workflow
- Edit workflow
- Run workflow (Web Call)
- View results
- Check what works and what doesn't

Write down what you find - that's it!

