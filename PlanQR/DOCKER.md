# PlanQR - Docker Setup Guide

> 💡 **Looking for automatic GitHub updates?** See [PORTAINER-QUICKSTART.md](PORTAINER-QUICKSTART.md) and [PORTAINER.md](PORTAINER.md) for Portainer setup with auto-update!

This guide explains how to run the PlanQR application using Docker and Docker Compose.

## Prerequisites

- Docker Engine 20.10 or later
- Docker Compose 2.0 or later
- At least 2GB of free disk space

## Quick Start

### 1. Clone the repository and navigate to the PlanQR directory

```bash
cd PlanQR
```

### 2. Generate SSL certificates (for development)

```bash
./generate-certs.sh localhost
```

Enter a password when prompted and remember it for the next step.

### 3. Configure environment variables

Copy the example environment files and edit them:

```bash
cp .env.example .env
cp client-app/.env.example client-app/.env
```

Edit `.env` and set the required values:
- `JwtSettings__SecretKey` - At least 32 characters long secret key
- `JwtSettings__Issuer` - Your domain URL (e.g., https://localhost)
- `JwtSettings__Audience` - Your domain URL (e.g., https://localhost)
- `SiteSettings__SiteUrl` - Your domain URL (e.g., https://localhost:5000)
- `CertificateSettings__PfxPassword` - The password you used when generating certificates

Edit `client-app/.env` and set:
- `VITE_SITE_URL` - Your domain URL (e.g., https://localhost:5000)

### 4. Create data directory

```bash
mkdir -p data
```

### 5. Build and start the application

```bash
docker-compose up -d
```

This will:
- Build the API backend container
- Build the frontend container
- Start both services
- Initialize the database

### 6. Access the application

- **Frontend**: http://localhost (or https://localhost:443 with your certificates)
- **API**: https://localhost:5000

## Management Commands

### View logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api
docker-compose logs -f frontend
```

### Stop the application

```bash
docker-compose down
```

### Stop and remove volumes (⚠️ this will delete the database)

```bash
docker-compose down -v
```

### Rebuild after code changes

```bash
docker-compose up -d --build
```

### Restart a specific service

```bash
docker-compose restart api
docker-compose restart frontend
```

## Production Deployment

For production deployment, consider the following:

### 1. Use valid SSL certificates

Replace the self-signed certificates in `./certs/` with valid certificates from a Certificate Authority (e.g., Let's Encrypt).

### 2. Update environment variables

Ensure all production values are set in `.env`:
- Use strong, randomly generated secrets
- Set proper domain names
- Configure LDAP settings if needed

### 3. Set up reverse proxy (recommended)

For production, it's recommended to use a reverse proxy like Nginx or Traefik in front of the application to handle:
- SSL termination
- Load balancing
- Rate limiting
- Security headers

### 4. Data persistence

The database is stored in the `./data` directory, which is mounted as a volume. Make sure to:
- Back up this directory regularly
- Set appropriate file permissions
- Consider using a more robust database for production

### 5. Resource limits

Edit `docker-compose.yml` to add resource limits:

```yaml
services:
  api:
    # ... other config ...
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
```

## Troubleshooting

### Certificate errors

If you see certificate errors:
1. Ensure certificates are properly generated in `./certs/`
2. Check that the PFX password matches in `.env`
3. Verify certificate files have correct permissions

### Database errors

If the database fails to initialize:
1. Check logs: `docker-compose logs api`
2. Ensure the `./data` directory exists and is writable
3. Try removing the database and restarting: `rm -rf data/* && docker-compose restart api`

### Port conflicts

If ports 80, 443, or 5000 are already in use, edit `docker-compose.yml` to use different ports:

```yaml
ports:
  - "8080:80"  # Frontend HTTP
  - "8443:443" # Frontend HTTPS
  - "5001:5000" # API
```

### Container won't start

1. Check logs: `docker-compose logs [service-name]`
2. Verify all required environment variables are set
3. Ensure Docker has enough resources (memory, disk space)

## Architecture

The Docker setup consists of:

- **API Container**: .NET 8.0 runtime running the backend API
- **Frontend Container**: Nginx serving the React application
- **Bridge Network**: Connects the containers
- **Data Volume**: Persists the SQLite database

```
┌─────────────────┐
│   Frontend      │
│   (Nginx)       │
│   Port 80/443   │
└────────┬────────┘
         │
    ┌────▼─────┐
    │ Network  │
    └────┬─────┘
         │
┌────────▼────────┐
│   API           │
│   (.NET 8)      │
│   Port 5000     │
└────────┬────────┘
         │
    ┌────▼─────┐
    │ Database │
    │ (SQLite) │
    └──────────┘
```

## Development

For development with hot reload:

1. Use the non-Docker development setup as described in the main README.md
2. Or modify docker-compose.yml to mount source code as volumes for live reloading

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [.NET in Docker](https://learn.microsoft.com/en-us/dotnet/core/docker/introduction)
