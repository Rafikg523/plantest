#!/bin/bash

# PlanQR Docker Setup Script
# This script helps you set up and run PlanQR with Docker

set -e

echo "======================================"
echo "   PlanQR Docker Setup"
echo "======================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

COMPOSE_CMD="docker-compose"
if ! command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker compose"
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env file and configure:"
    echo "   - JwtSettings__SecretKey (min 32 characters)"
    echo "   - JwtSettings__Issuer"
    echo "   - JwtSettings__Audience"
    echo "   - SiteSettings__SiteUrl"
    echo "   - CertificateSettings__PfxPassword"
    echo ""
    read -p "Press Enter when you've configured .env file..."
fi

# Check if client-app/.env file exists
if [ ! -f client-app/.env ]; then
    echo "📝 Creating client-app/.env file from template..."
    cp client-app/.env.example client-app/.env
    echo "⚠️  Please edit client-app/.env file and set VITE_SITE_URL"
    echo ""
    read -p "Press Enter when you've configured client-app/.env file..."
fi

# Check if certificates exist
if [ ! -f certs/cert.pfx ] || [ ! -f certs/cert.key ] || [ ! -f certs/cert.pem ]; then
    echo "🔐 SSL certificates not found. Generating self-signed certificates..."
    
    if [ ! -f generate-certs.sh ]; then
        echo "❌ generate-certs.sh script not found!"
        exit 1
    fi
    
    chmod +x generate-certs.sh
    ./generate-certs.sh localhost
    
    echo ""
    echo "⚠️  Remember to update CertificateSettings__PfxPassword in .env"
    echo ""
    read -p "Press Enter to continue..."
fi

# Create data directory
if [ ! -d data ]; then
    echo "📁 Creating data directory..."
    mkdir -p data
fi

# Ask user what to do
echo ""
echo "What would you like to do?"
echo "1) Build and start services"
echo "2) Start services (without rebuilding)"
echo "3) Stop services"
echo "4) View logs"
echo "5) Rebuild and restart"
echo "6) Exit"
echo ""
read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        echo "🏗️  Building and starting services..."
        $COMPOSE_CMD up -d --build
        echo ""
        echo "✅ Services started successfully!"
        echo "   Frontend: http://localhost"
        echo "   API: https://localhost:5000"
        echo ""
        echo "To view logs, run: $COMPOSE_CMD logs -f"
        ;;
    2)
        echo "🚀 Starting services..."
        $COMPOSE_CMD up -d
        echo ""
        echo "✅ Services started successfully!"
        echo "   Frontend: http://localhost"
        echo "   API: https://localhost:5000"
        ;;
    3)
        echo "🛑 Stopping services..."
        $COMPOSE_CMD down
        echo "✅ Services stopped successfully!"
        ;;
    4)
        echo "📋 Viewing logs (Ctrl+C to exit)..."
        $COMPOSE_CMD logs -f
        ;;
    5)
        echo "🔄 Rebuilding and restarting services..."
        $COMPOSE_CMD down
        $COMPOSE_CMD up -d --build
        echo ""
        echo "✅ Services rebuilt and restarted successfully!"
        ;;
    6)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice. Exiting."
        exit 1
        ;;
esac
