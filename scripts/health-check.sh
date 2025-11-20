#!/bin/bash

# =================================================================
# VoiceFX AI - Health Check Script
# =================================================================
# Monitors the health of all services and sends alerts if needed
# Usage: ./scripts/health-check.sh [--alert]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
COMPOSE_FILE="docker-compose.prod.yaml"
ALERT_MODE=false
WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"  # Set in environment or .env.production

# Parse arguments
if [ "$1" = "--alert" ]; then
    ALERT_MODE=true
fi

log_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

send_alert() {
    local message=$1
    if [ "$ALERT_MODE" = true ] && [ -n "$WEBHOOK_URL" ]; then
        curl -X POST "$WEBHOOK_URL" \
            -H 'Content-Type: application/json' \
            -d "{\"text\":\"🚨 VoiceFX Alert: $message\"}" \
            2>/dev/null
    fi
}

check_service_health() {
    local service=$1
    local health=$(docker compose -f "$COMPOSE_FILE" ps --format json "$service" 2>/dev/null | jq -r '.[0].Health // "unknown"')

    if [ "$health" = "healthy" ]; then
        log_ok "$service is healthy"
        return 0
    else
        log_error "$service is $health"
        send_alert "$service is $health"
        return 1
    fi
}

check_http_endpoint() {
    local name=$1
    local url=$2
    local expected_status=${3:-200}

    status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")

    if [ "$status" = "$expected_status" ]; then
        log_ok "$name endpoint is responding ($status)"
        return 0
    else
        log_error "$name endpoint returned $status (expected $expected_status)"
        send_alert "$name endpoint check failed (HTTP $status)"
        return 1
    fi
}

check_disk_space() {
    local threshold=90
    local usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

    if [ "$usage" -lt "$threshold" ]; then
        log_ok "Disk usage: ${usage}%"
        return 0
    else
        log_warn "Disk usage: ${usage}% (threshold: ${threshold}%)"
        send_alert "High disk usage: ${usage}%"
        return 1
    fi
}

check_memory() {
    local threshold=90
    local usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')

    if [ "$usage" -lt "$threshold" ]; then
        log_ok "Memory usage: ${usage}%"
        return 0
    else
        log_warn "Memory usage: ${usage}% (threshold: ${threshold}%)"
        send_alert "High memory usage: ${usage}%"
        return 1
    fi
}

check_docker_running() {
    if docker info >/dev/null 2>&1; then
        log_ok "Docker daemon is running"
        return 0
    else
        log_error "Docker daemon is not running!"
        send_alert "Docker daemon is not running"
        return 1
    fi
}

# Main health check
echo "========================================"
echo "VoiceFX AI Health Check"
echo "Time: $(date)"
echo "========================================"
echo ""

overall_health=0

# Check Docker
echo "🐳 Docker Status"
check_docker_running || overall_health=1
echo ""

# Check disk and memory
echo "💾 System Resources"
check_disk_space || overall_health=1
check_memory || overall_health=1
echo ""

# Check service health
echo "🏥 Service Health"
check_service_health "postgres" || overall_health=1
check_service_health "redis" || overall_health=1
check_service_health "minio" || overall_health=1
check_service_health "api" || overall_health=1
check_service_health "ui" || overall_health=1
echo ""

# Check HTTP endpoints (adjust URLs for your domain)
echo "🌐 HTTP Endpoints"
# Uncomment these when deployed to production with real domain
# check_http_endpoint "API Health" "https://api.yourdomain.com/api/v1/health" || overall_health=1
# check_http_endpoint "UI" "https://yourdomain.com" || overall_health=1

# Check localhost endpoints
if curl -f http://localhost:8000/api/v1/health >/dev/null 2>&1; then
    log_ok "API Health endpoint (localhost:8000)"
else
    log_error "API Health endpoint check failed"
    overall_health=1
fi

if curl -f http://localhost:3010 >/dev/null 2>&1; then
    log_ok "UI endpoint (localhost:3010)"
else
    log_error "UI endpoint check failed"
    overall_health=1
fi

echo ""

# Summary
echo "========================================"
if [ $overall_health -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
else
    echo -e "${RED}✗ Some checks failed!${NC}"
    send_alert "Health check failed - please investigate"
fi
echo "========================================"

exit $overall_health
