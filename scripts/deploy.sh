#!/bin/bash

# =================================================================
# VoiceFX AI - Production Deployment Script
# =================================================================
# This script handles deployment of the VoiceFX AI platform
# Usage: ./scripts/deploy.sh [command]
# Commands: setup, start, stop, restart, logs, backup, restore

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.prod.yaml"
ENV_FILE=".env.production"
BACKUP_DIR="./backups"

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    log_info "Checking requirements..."

    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi

    if ! command -v docker compose &> /dev/null; then
        log_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi

    log_info "Requirements check passed!"
}

check_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        log_error "Environment file $ENV_FILE not found!"
        log_info "Please copy .env.production.example to $ENV_FILE and configure it."
        exit 1
    fi

    # Check for placeholder values
    if grep -q "CHANGE_THIS" "$ENV_FILE"; then
        log_warn "Environment file contains placeholder values (CHANGE_THIS)."
        log_warn "Please update all credentials before deploying to production!"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

setup() {
    log_info "Setting up VoiceFX AI for production deployment..."

    check_requirements
    check_env_file

    # Create necessary directories
    log_info "Creating directories..."
    mkdir -p nginx/conf.d nginx/ssl nginx/logs
    mkdir -p backups/{postgres,redis,minio}
    mkdir -p logs/api

    # Pull latest images
    log_info "Pulling latest Docker images..."
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull

    # Run database migrations
    log_info "Running database migrations..."
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" run --rm api alembic upgrade head

    log_info "Setup complete!"
    log_warn "Next steps:"
    log_warn "1. Configure SSL certificates (run ./scripts/setup-ssl.sh)"
    log_warn "2. Update nginx/conf.d/voicefx.conf with your domain"
    log_warn "3. Start the application with: ./scripts/deploy.sh start"
}

start() {
    log_info "Starting VoiceFX AI..."
    check_env_file

    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d

    log_info "Application started!"
    log_info "Waiting for services to be healthy..."
    sleep 10

    # Check service health
    docker compose -f "$COMPOSE_FILE" ps

    log_info "Access the application at:"
    log_info "  UI: https://yourdomain.com"
    log_info "  API: https://api.yourdomain.com"
}

stop() {
    log_info "Stopping VoiceFX AI..."
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down
    log_info "Application stopped."
}

restart() {
    log_info "Restarting VoiceFX AI..."
    stop
    sleep 5
    start
}

logs() {
    service=${1:-all}
    if [ "$service" = "all" ]; then
        docker compose -f "$COMPOSE_FILE" logs -f
    else
        docker compose -f "$COMPOSE_FILE" logs -f "$service"
    fi
}

backup() {
    log_info "Creating backup..."

    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP"
    mkdir -p "$BACKUP_PATH"

    # Backup PostgreSQL
    log_info "Backing up PostgreSQL..."
    docker compose -f "$COMPOSE_FILE" exec -T postgres pg_dump -U postgres postgres > "$BACKUP_PATH/postgres_dump.sql"

    # Backup Redis
    log_info "Backing up Redis..."
    docker compose -f "$COMPOSE_FILE" exec -T redis redis-cli -a "${REDIS_PASSWORD}" --rdb - > "$BACKUP_PATH/redis_dump.rdb"

    # Backup MinIO (using mc client if available)
    log_info "Backing up MinIO data..."
    docker compose -f "$COMPOSE_FILE" exec -T minio sh -c "tar czf - /data" > "$BACKUP_PATH/minio_data.tar.gz"

    # Compress backup
    log_info "Compressing backup..."
    tar czf "$BACKUP_PATH.tar.gz" -C "$BACKUP_DIR" "backup_$TIMESTAMP"
    rm -rf "$BACKUP_PATH"

    log_info "Backup created: $BACKUP_PATH.tar.gz"
}

restore() {
    backup_file=$1

    if [ -z "$backup_file" ]; then
        log_error "Please specify backup file: ./scripts/deploy.sh restore <backup_file>"
        exit 1
    fi

    if [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: $backup_file"
        exit 1
    fi

    log_warn "This will restore from backup and overwrite current data!"
    read -p "Are you sure? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi

    log_info "Restoring from backup: $backup_file"

    # Extract backup
    TEMP_DIR=$(mktemp -d)
    tar xzf "$backup_file" -C "$TEMP_DIR"
    BACKUP_DIR_NAME=$(ls "$TEMP_DIR")

    # Restore PostgreSQL
    log_info "Restoring PostgreSQL..."
    cat "$TEMP_DIR/$BACKUP_DIR_NAME/postgres_dump.sql" | docker compose -f "$COMPOSE_FILE" exec -T postgres psql -U postgres postgres

    log_info "Restore complete!"
    rm -rf "$TEMP_DIR"
}

update() {
    log_info "Updating VoiceFX AI..."

    # Pull latest images
    log_info "Pulling latest images..."
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull

    # Run migrations
    log_info "Running database migrations..."
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" run --rm api alembic upgrade head

    # Restart services
    log_info "Restarting services..."
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d

    log_info "Update complete!"
}

status() {
    log_info "VoiceFX AI Status:"
    docker compose -f "$COMPOSE_FILE" ps

    echo ""
    log_info "Resource Usage:"
    docker stats --no-stream $(docker compose -f "$COMPOSE_FILE" ps -q)
}

# Main script
case "${1:-}" in
    setup)
        setup
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    logs)
        logs "${2:-all}"
        ;;
    backup)
        backup
        ;;
    restore)
        restore "$2"
        ;;
    update)
        update
        ;;
    status)
        status
        ;;
    *)
        echo "VoiceFX AI Deployment Script"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  setup     - Initial setup (create dirs, pull images, run migrations)"
        echo "  start     - Start all services"
        echo "  stop      - Stop all services"
        echo "  restart   - Restart all services"
        echo "  logs      - View logs (optionally specify service: logs api)"
        echo "  backup    - Create a backup of databases and data"
        echo "  restore   - Restore from backup file"
        echo "  update    - Pull latest images and update deployment"
        echo "  status    - Show service status and resource usage"
        echo ""
        exit 1
        ;;
esac
