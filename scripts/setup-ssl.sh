#!/bin/bash

# =================================================================
# VoiceFX AI - SSL Certificate Setup with Let's Encrypt
# =================================================================
# This script sets up SSL certificates using Certbot and Let's Encrypt
# Usage: ./scripts/setup-ssl.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get domain from user
read -p "Enter your domain name (e.g., yourdomain.com): " DOMAIN
read -p "Enter your email for Let's Encrypt notifications: " EMAIL

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    log_error "Domain and email are required!"
    exit 1
fi

log_info "Setting up SSL for domain: $DOMAIN"

# Create certbot directory
mkdir -p certbot/conf certbot/www

# Check if running with docker compose
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

# Create temporary certbot configuration
cat > certbot-compose.yaml <<EOF
version: '3.8'
services:
  certbot:
    image: certbot/certbot
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait \$\${!}; done;'"
EOF

# Get initial certificate
log_info "Requesting certificate from Let's Encrypt..."
log_warn "Make sure your domain DNS points to this server!"
read -p "Press enter to continue..."

docker run --rm \
    -v "$(pwd)/certbot/conf:/etc/letsencrypt" \
    -v "$(pwd)/certbot/www:/var/www/certbot" \
    certbot/certbot certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    -d "$DOMAIN" \
    -d "www.$DOMAIN" \
    -d "api.$DOMAIN" \
    -d "app.$DOMAIN"

if [ $? -eq 0 ]; then
    log_info "SSL certificate obtained successfully!"

    # Copy certificates to nginx ssl directory
    mkdir -p nginx/ssl
    cp "certbot/conf/live/$DOMAIN/fullchain.pem" nginx/ssl/
    cp "certbot/conf/live/$DOMAIN/privkey.pem" nginx/ssl/

    # Update nginx configuration with actual domain
    log_info "Updating nginx configuration..."
    sed -i.bak "s/yourdomain.com/$DOMAIN/g" nginx/conf.d/voicefx.conf
    rm nginx/conf.d/voicefx.conf.bak

    log_info "SSL setup complete!"
    log_info "Certificates are stored in: nginx/ssl/"
    log_warn "Remember to set up certificate renewal!"
    log_info "You can use: docker run --rm -v \$(pwd)/certbot/conf:/etc/letsencrypt certbot/certbot renew"

else
    log_error "Failed to obtain SSL certificate!"
    log_error "Make sure:"
    log_error "  1. Your domain DNS is pointing to this server"
    log_error "  2. Port 80 is accessible from the internet"
    log_error "  3. No firewall is blocking the connection"
    exit 1
fi

# Create renewal script
cat > scripts/renew-ssl.sh <<'EOF'
#!/bin/bash
# SSL Certificate Renewal Script
# Add to cron: 0 0 * * 0 /path/to/scripts/renew-ssl.sh

docker run --rm \
    -v "$(pwd)/certbot/conf:/etc/letsencrypt" \
    -v "$(pwd)/certbot/www:/var/www/certbot" \
    certbot/certbot renew

# Copy renewed certificates
if [ -d "certbot/conf/live" ]; then
    DOMAIN=$(ls certbot/conf/live | head -n1)
    cp "certbot/conf/live/$DOMAIN/fullchain.pem" nginx/ssl/
    cp "certbot/conf/live/$DOMAIN/privkey.pem" nginx/ssl/

    # Reload nginx
    docker compose -f docker-compose.prod.yaml exec nginx nginx -s reload
    echo "SSL certificates renewed and nginx reloaded!"
fi
EOF

chmod +x scripts/renew-ssl.sh

log_info "Created renewal script: scripts/renew-ssl.sh"
log_warn "Add this to your crontab to auto-renew certificates:"
log_info "  0 0 * * 0 $(pwd)/scripts/renew-ssl.sh"
