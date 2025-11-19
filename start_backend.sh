#!/bin/bash
cd "$(dirname "$0")"
source api/venv/bin/activate
export $(cat api/.env | xargs)
uvicorn api.app:app --reload --port 8000

