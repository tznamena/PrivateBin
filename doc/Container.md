# PrivateBin Container Development Environment

This document provides comprehensive information about the Docker-based development and production environment for PrivateBin.

## Overview

PrivateBin includes a complete containerized development environment that provides:
- **Instant setup** with `make docker-dev`
- **Multiple storage backends** for comprehensive testing
- **Development tools** including debugging, testing, and documentation generation
- **Production-ready deployment** configurations
- **Cross-platform compatibility** (Linux, macOS, Windows)

## Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Make (for convenient commands)

### Start Development Environment

```bash
# Clone and enter the project
git clone https://github.com/PrivateBin/PrivateBin.git
cd PrivateBin

# Start the complete development environment
make docker-dev

# Access the application
open http://localhost:8080
```

## Architecture

### Container Structure

The Docker setup uses a multi-stage Dockerfile with the following stages:

1. **Base Stage** (`php:8.2-apache`)
   - PHP 8.2 with Apache web server
   - Essential PHP extensions: `zip`, `gd`, `pdo`, `pdo_sqlite`, `pdo_mysql`
   - Apache modules: `rewrite`, `headers`
   - Security configurations

2. **Development Stage** (extends base)
   - Node.js and NPM for JavaScript testing
   - Xdebug for debugging and coverage
   - Development PHP settings (error reporting, memory limits)
   - Composer for dependency management
   - Development tools and utilities

3. **Production Stage** (extends base)
   - Optimized PHP settings
   - Security hardening
   - Minimal attack surface
   - Health checks

### Service Architecture

The development environment includes:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PrivateBin    │    │     MySQL       │    │     Redis       │
│   (PHP/Apache)  │    │   (Database)    │    │   (Sessions)    │
│   Port: 8080    │    │   Port: 3306    │    │   Port: 6379    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
┌─────────────────┐    ┌─────────────────┐
│     Adminer     │    │     MinIO       │
│  (DB Admin UI)  │    │  (S3 Storage)   │
│   Port: 8081    │    │   Port: 9000/1  │
└─────────────────┘    └─────────────────┘
```

## File Structure

```
PrivateBin/
├── docker/                       # Container configuration directory
│   ├── Dockerfile                # Multi-stage container definition
│   ├── docker-compose.yml        # Development environment
│   ├── docker-compose.prod.yml   # Production environment
│   ├── .dockerignore             # Files excluded from build context
│   ├── docker.env.example        # Environment variables template
│   ├── apache/                   # Apache configurations
│   │   ├── privatebin.conf       # Development Apache config
│   │   └── privatebin-prod.conf  # Production Apache config
│   ├── mysql/                    # Database initialization
│   │   ├── init.sql              # Development schema
│   │   └── init-prod.sql         # Production schema
│   ├── entrypoint-dev.sh         # Development startup script
│   └── entrypoint-prod.sh        # Production startup script
├── doc/
│   └── Container.md              # This documentation
├── DOCKER.md                     # User-facing Docker guide
└── CLAUDE.md                     # Claude AI context file
```

## Development Environment

### Services

#### PrivateBin Application
- **Container**: `privatebin-dev`
- **Image**: Custom build from `Dockerfile` (development stage)
- **Port**: 8080
- **Features**:
  - Live code reloading via volume mounts
  - Xdebug debugging on port 9003
  - Development configuration auto-generated
  - PHP and JavaScript dependency management

#### MySQL Database
- **Container**: `mysql-dev`
- **Image**: `mysql:8.0`
- **Port**: 3306
- **Credentials**:
  - Database: `privatebin_dev`
  - User: `privatebin`
  - Password: `privatebin_dev_pass`
- **Features**:
  - Auto-initialization with PrivateBin schema
  - Persistent data storage
  - Development-friendly configuration

#### Redis Cache
- **Container**: `redis-dev`
- **Image**: `redis:7-alpine`
- **Port**: 6379
- **Features**:
  - Session storage
  - Caching layer
  - Persistent AOF storage

#### MinIO S3 Storage
- **Container**: `minio-dev`
- **Image**: `minio/minio:latest`
- **Ports**: 9000 (API), 9001 (Console)
- **Credentials**: `minioadmin` / `minioadmin`
- **Features**:
  - S3-compatible storage testing
  - Web-based management console
  - Bucket management

#### Adminer Database Admin
- **Container**: `adminer`
- **Image**: `adminer:latest`
- **Port**: 8081
- **Features**:
  - Web-based database administration
  - Direct MySQL connection
  - SQL query interface

### Volume Mounts

```yaml
volumes:
  # Source code (live reload)
  - .:/var/www/html:cached
  
  # Persistent data
  - privatebin_data:/var/www/html/data
  
  # Vendor dependencies (performance)
  - privatebin_vendor:/var/www/html/vendor
  
  # Isolated node_modules
  - /var/www/html/js/node_modules
```

### Environment Variables

```bash
# Debugging
XDEBUG_MODE=debug,coverage
XDEBUG_CONFIG=client_host=host.docker.internal client_port=9003
PHP_IDE_CONFIG=serverName=privatebin-dev

# Application (optional overrides)
PRIVATEBIN_NAME=PrivateBin
PRIVATEBIN_BASEPATH=https://paste.example.com/
```

## Production Environment

### Security Features

- **Non-root user execution**
- **Security headers** (CSP, HSTS, XSS Protection)
- **Minimal attack surface**
- **Read-only configurations** where possible
- **Health checks** for monitoring

### Environment Configuration

Production deployment supports environment-based configuration:

```bash
# Application
PRIVATEBIN_NAME=MyPrivateBin
PRIVATEBIN_BASEPATH=https://paste.company.com/

# Database
MYSQL_ROOT_PASSWORD=secure_root_password
MYSQL_DATABASE=privatebin
MYSQL_USER=privatebin
MYSQL_PASSWORD=secure_password

# S3 Storage (optional)
S3_ENDPOINT=https://s3.amazonaws.com
S3_REGION=us-east-1
S3_BUCKET=privatebin-data
S3_ACCESS_KEY=your_access_key
S3_SECRET_KEY=your_secret_key
```

## Available Commands

### Development Commands

| Command | Description | Notes |
|---------|-------------|-------|
| `make docker-build` | Build development image | Rebuilds from Dockerfile |
| `make docker-dev` | Start development environment | Runs all services |
| `make docker-test` | Run all tests in container | PHP + JavaScript tests |
| `make docker-test-php` | Run PHP unit tests | Uses PHPUnit |
| `make docker-test-js` | Run JavaScript tests | Uses Mocha |
| `make docker-coverage` | Generate coverage reports | Xdebug + NYC |
| `make docker-shell` | Open shell in container | Root access for debugging |
| `make docker-logs` | Show logs (30s timeout) | All services |
| `make docker-stop` | Stop all services | Preserves volumes |
| `make docker-restart` | Restart PrivateBin service | Quick restart |
| `make docker-clean` | Remove everything | Containers + volumes + images |

### Production Commands

| Command | Description |
|---------|-------------|
| `make docker-prod` | Start production environment |
| `make docker-prod-stop` | Stop production services |
| `make docker-prod-logs` | Show production logs (30s timeout) |

## Storage Backend Testing

### Filesystem Storage (Default)
```php
# No configuration needed - uses data/ directory
# Automatically configured in development
```

### Database Storage
```php
[model]
class = Database

[model_options]
dsn = "mysql:host=mysql-dev;dbname=privatebin_dev"
username = "privatebin"
password = "privatebin_dev_pass"
prefix = "pb_"
```

### S3 Storage (MinIO)
```php
[model]
class = S3Storage

[model_options]
region = ""
version = "2006-03-01"
endpoint = "http://minio-dev:9000"
use_path_style_endpoint = true
bucket = "privatebin"
prefix = "pastes"
accesskey = "minioadmin"
secretkey = "minioadmin"
```

### Google Cloud Storage
```php
[model]
class = GoogleCloudStorage

[model_options]
bucket = "your-gcs-bucket"
prefix = "privatebin"
```

## Development Workflow

### Typical Development Session

1. **Environment Setup**
   ```bash
   make docker-dev
   ```

2. **Code Development**
   - Edit files in your IDE
   - Changes are immediately reflected (live reload)
   - Access application at http://localhost:8080

3. **Testing**
   ```bash
   # Run all tests
   make docker-test
   
   # Run specific test suites
   make docker-test-php
   make docker-test-js
   
   # Generate coverage
   make docker-coverage
   ```

4. **Debugging**
   ```bash
   # View logs
   make docker-logs
   
   # Interactive debugging
   make docker-shell
   
   # Or use Xdebug with your IDE
   ```

5. **Cleanup**
   ```bash
   make docker-stop
   ```

### Testing Storage Backends Workflow

1. **Start with Filesystem** (default)
   - Test basic functionality
   - Verify file upload/download
   - Check data persistence

2. **Switch to Database**
   - Modify `cfg/conf.php` with database settings
   - Restart: `make docker-restart`
   - Test paste creation/retrieval
   - Verify database tables via Adminer

3. **Test S3 Storage**
   - Configure MinIO settings in `cfg/conf.php`
   - Create bucket via MinIO console (http://localhost:9001)
   - Restart and test
   - Verify object storage

4. **Performance Testing**
   - Use different storage backends
   - Compare response times
   - Test with large pastes
   - Monitor resource usage

### Storage Backend Testing Workflow

1. **Start with Filesystem** (default)
   - Test basic functionality
   - Verify file upload/download

2. **Switch to Database**
   - Modify `cfg/conf.php` with database settings
   - Restart: `make docker-restart`
   - Test paste creation/retrieval

3. **Test S3 Storage**
   - Configure MinIO settings in `cfg/conf.php`
   - Create bucket via MinIO console (http://localhost:9001)
   - Restart and test

4. **Performance Testing**
   - Use different storage backends
   - Compare response times
   - Test with large pastes

### Debugging Setup

#### VS Code Configuration

Create `.vscode/launch.json`:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug (Docker)",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www/html": "${workspaceFolder}"
            },
            "ignore": [
                "**/vendor/**/*.php"
            ]
        }
    ]
}
```

#### PHPStorm Configuration

1. **Server Configuration**:
   - Name: `privatebin-dev`
   - Host: `localhost`
   - Port: `8080`
   - Path mappings: `<project_root>` → `/var/www/html`

2. **Debug Configuration**:
   - Port: `9003`
   - IDE key: `PHPSTORM`

## Performance Considerations

### Development

- **Volume Performance**: Uses cached mounts for better performance
- **Dependency Caching**: Vendor directory persisted via named volume
- **Resource Limits**: Configure via Docker if needed

### Production

- **Multi-stage Builds**: Optimized image sizes
- **Security**: Non-root execution, minimal packages
- **Health Checks**: Monitoring integration ready
- **Scaling**: Horizontal scaling with external database

## Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check logs
make docker-logs

# Rebuild from scratch
make docker-clean
make docker-build
make docker-dev
```

#### Permission Issues
```bash
# Fix data directory permissions
sudo chown -R $USER:$USER data/
sudo chmod -R 755 data/
```

#### Database Connection Issues
```bash
# Check MySQL status
docker compose exec mysql-dev mysql -u privatebin -p privatebin_dev

# Reset database
make docker-stop
docker volume rm privatebin_mysql_dev_data
make docker-dev
```

#### Application Not Accessible
```bash
# Check container status
docker compose ps

# Check specific service logs
docker compose logs privatebin-dev

# Verify port mapping
netstat -tlnp | grep 8080
```

### Debug Commands

```bash
# Container inspection
docker compose exec privatebin-dev bash
docker compose exec mysql-dev bash

# View configuration
docker compose exec privatebin-dev cat cfg/conf.php

# Check Apache status
docker compose exec privatebin-dev apache2ctl status

# PHP information
docker compose exec privatebin-dev php -m
docker compose exec privatebin-dev php -v
```

## Security Considerations

### Development Environment

- **Network Isolation**: Services communicate via Docker network
- **Credential Management**: Development credentials only
- **File Permissions**: Proper user/group assignment
- **Debug Mode**: Only enabled in development

### Production Environment

- **Secrets Management**: Use Docker secrets or environment variables
- **SSL/TLS**: Configure reverse proxy (Nginx/Traefik)
- **Database Security**: External database recommended
- **Monitoring**: Health checks and logging
- **Updates**: Regular base image updates

## Monitoring and Logging

### Health Checks

```yaml
# Built-in health checks
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Log Management

```bash
# View logs with timestamp
docker compose logs -t privatebin-dev

# Follow specific service
docker compose logs -f mysql-dev

# Export logs
docker compose logs > privatebin-logs.txt
```

### Metrics Collection

- **Application Metrics**: PHP-FPM status, Apache mod_status
- **Database Metrics**: MySQL performance schema
- **Container Metrics**: Docker stats, resource usage
- **Storage Metrics**: Disk usage, I/O performance

## Backup and Recovery

### Development Data

```bash
# Backup volumes
docker run --rm -v privatebin_privatebin_data:/data -v $(pwd):/backup alpine tar czf /backup/data-backup.tar.gz -C /data .

# Restore volumes
docker run --rm -v privatebin_privatebin_data:/data -v $(pwd):/backup alpine tar xzf /backup/data-backup.tar.gz -C /data
```

### Database Backup

```bash
# Export database
docker compose exec mysql-dev mysqldump -u privatebin -p privatebin_dev > backup.sql

# Import database
docker compose exec -T mysql-dev mysql -u privatebin -p privatebin_dev < backup.sql
```

## Contributing

### Adding New Features

1. **Create feature branch** from main/master
2. **Start development environment** with `make docker-dev`
3. **Write code and tests** using live reload
4. **Run test suite** with `make docker-test`
5. **Test storage backends** by switching configurations
6. **Generate documentation** if API changes
7. **Update container configs** if new dependencies needed:
   - Modify `Dockerfile` for new system packages
   - Update `docker-compose.yml` for new services
   - Add `Makefile` targets for new commands
8. **Update documentation** in this file and `DOCKER.md`
9. **Submit pull request** with comprehensive testing

### Testing Changes

1. **Clean Environment**: `make docker-clean`
2. **Fresh Build**: `make docker-build`
3. **Test All Features**: `make docker-dev && make docker-test`
4. **Storage Backend Tests**: Test all supported backends
5. **Production Build**: Test production image

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Docker Tests
on: [push, pull_request]
jobs:
  docker-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      - name: Build and test
        run: |
          make docker-build
          make docker-dev
          sleep 30  # Wait for services to be ready
          make docker-test
          make docker-stop
      - name: Build production image
        run: |
          docker build --target production -t privatebin/privatebin:${{ github.sha }} .
```

### Docker Hub Integration

```bash
# Build and tag production image
docker build --target production -t privatebin/privatebin:latest .
docker build --target production -t privatebin/privatebin:2.0.0 .

# Push to registry
docker push privatebin/privatebin:latest
docker push privatebin/privatebin:2.0.0
```

### Deployment Automation

```bash
# Deploy to staging
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d

# Health check before production deployment
curl -f http://staging.privatebin.com/health || exit 1
```

## Important Links

- **User Documentation**: See `/DOCKER.md` for user-friendly Docker setup guide
- **Project Context**: See `/CLAUDE.md` for comprehensive project context
- **Main Documentation**: See `/doc/Installation.md` for traditional installation
- **Configuration Guide**: PrivateBin Wiki Configuration page

This container environment provides a complete, production-ready development setup that matches the production deployment while offering all the tools needed for effective development and testing.