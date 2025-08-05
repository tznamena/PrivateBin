# PrivateBin Docker Development Environment

This document describes how to use the Docker development environment for PrivateBin.

## Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Make (for convenient commands)

### Start Development Environment

```bash
# Build and start the development environment
make docker-dev

# Access the application
open http://localhost:8080
```

That's it! The development environment will be running with:
- PrivateBin application on http://localhost:8080
- MySQL database with sample data
- Adminer (database admin) on http://localhost:8081
- MinIO (S3-compatible storage) console on http://localhost:9001
- Redis for caching/sessions

## Available Make Commands

### Development Commands

| Command | Description |
|---------|-------------|
| `make docker-build` | Build the development Docker image |
| `make docker-dev` | Start development environment with live reload |
| `make docker-test` | Run all tests in Docker container |
| `make docker-test-php` | Run PHP unit tests in Docker container |
| `make docker-test-js` | Run JavaScript unit tests in Docker container |
| `make docker-coverage` | Generate coverage reports in Docker container |
| `make docker-shell` | Open shell in running development container |
| `make docker-logs` | Show logs from development containers (30s timeout) |
| `make docker-stop` | Stop development environment |
| `make docker-restart` | Restart development environment |
| `make docker-clean` | Clean up Docker containers, images and volumes |

### Production Commands

| Command | Description |
|---------|-------------|
| `make docker-prod` | Build and start production environment |
| `make docker-prod-stop` | Stop production environment |
| `make docker-prod-logs` | Show logs from production containers (30s timeout) |

## Development Features

### Live Code Reloading

The development environment mounts your source code as a volume, so any changes you make to PHP, JavaScript, or template files will be immediately reflected in the running application.

### Debugging Support

The development container includes Xdebug configured for debugging:

- **Host**: `host.docker.internal`
- **Port**: `9003`
- **Server Name**: `privatebin-dev`

To debug in VS Code:
1. Install the PHP Debug extension
2. Add this configuration to your `.vscode/launch.json`:

```json
{
    "name": "Listen for Xdebug (Docker)",
    "type": "php",
    "request": "launch",
    "port": 9003,
    "pathMappings": {
        "/var/www/html": "${workspaceFolder}"
    }
}
```

### Testing

Run the complete test suite in the Docker environment:

```bash
# Run all tests
make docker-test

# Run only PHP tests
make docker-test-php

# Run only JavaScript tests
make docker-test-js

# Generate coverage reports
make docker-coverage
```

Test results and coverage reports will be available in the `tst/` directory.

### Database Testing

The development environment includes MySQL for testing database storage:

- **Host**: `mysql-dev` (from within Docker) or `localhost:3306` (from host)
- **Database**: `privatebin_dev`
- **Username**: `privatebin`
- **Password**: `privatebin_dev_pass`

Access via Adminer: http://localhost:8081

### S3 Storage Testing

MinIO provides S3-compatible storage for testing:

- **Console**: http://localhost:9001
- **API Endpoint**: http://minio-dev:9000
- **Access Key**: `minioadmin`
- **Secret Key**: `minioadmin`

## Storage Backend Configuration

### Filesystem Storage (Default)

No additional configuration needed. Data is stored in the `data/` directory which is persisted via Docker volumes.

### Database Storage

To test with database storage, modify `cfg/conf.php`:

```php
[model]
class = Database

[model_options]
dsn = "mysql:host=mysql-dev;dbname=privatebin_dev"
username = "privatebin"
password = "privatebin_dev_pass"
prefix = "pb_"
```

### S3 Storage

To test with S3 storage using MinIO:

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

## Production Deployment

### Environment Configuration

Copy the example environment file and customize:

```bash
cp docker.env.example .env
# Edit .env with your production settings
```

### Start Production Environment

```bash
make docker-prod
```

This starts:
- PrivateBin application (production optimized)
- MySQL database
- Nginx reverse proxy (if configured)
- Redis for sessions

### Production Security Notes

1. **Change default passwords** in `.env` file
2. **Configure SSL/TLS** with proper certificates
3. **Use external database** for production workloads
4. **Configure backup strategy** for data persistence
5. **Set up monitoring** and logging
6. **Review security headers** in Apache/Nginx configuration

## Advanced Configuration

### Custom PHP Configuration

Create `docker/php/custom.ini` for custom PHP settings:

```ini
memory_limit = 512M
upload_max_filesize = 100M
post_max_size = 100M
```

Rebuild the image after changes:

```bash
make docker-build
```

### Custom Apache Configuration

Modify `docker/apache/privatebin.conf` for custom Apache settings.

### Database Initialization

Custom database schemas can be added to:
- `docker/mysql/init.sql` (development)
- `docker/mysql/init-prod.sql` (production)

## Troubleshooting

### Container Won't Start

```bash
# Check container logs
make docker-logs

# Rebuild from scratch
make docker-clean
make docker-build
make docker-dev
```

### Permission Issues

```bash
# Fix file permissions
sudo chown -R $USER:$USER data/
sudo chmod -R 755 data/
```

### Database Connection Issues

```bash
# Check if MySQL is running
docker-compose ps

# Connect to database directly
docker-compose exec mysql-dev mysql -u privatebin -p privatebin_dev
```

### Clear All Data

```bash
# Stop and remove all containers, volumes, and images
make docker-clean
```

## Development Workflow

### Typical Development Session

1. Start the environment:
   ```bash
   make docker-dev
   ```

2. Make code changes in your editor

3. Test changes:
   ```bash
   make docker-test
   ```

4. Debug if needed:
   ```bash
   make docker-shell
   # or use Xdebug with your IDE
   ```

5. Stop when done:
   ```bash
   make docker-stop
   ```

### Adding New Features

1. Create feature branch
2. Start development environment
3. Write code and tests
4. Run test suite
5. Generate documentation
6. Submit pull request

### Testing Storage Backends

Switch between storage backends by modifying `cfg/conf.php` and restarting:

```bash
make docker-restart
```

## Performance Considerations

### Development

- Use Docker volumes for better performance on macOS/Windows
- Limit container resources if running on constrained systems
- Use cached volume mounts for node_modules

### Production

- Use multi-stage builds for smaller images
- Enable read-only root filesystem
- Configure resource limits
- Use external databases for better performance
- Implement proper caching strategies

## Contributing

When contributing to the Docker setup:

1. Test both development and production configurations
2. Update documentation for any new features
3. Ensure backward compatibility with existing workflows
4. Add appropriate health checks and monitoring

## Support

For Docker-specific issues:
- Check existing GitHub issues
- Review container logs with `make docker-logs`
- Test with clean environment using `make docker-clean`

For general PrivateBin issues, refer to the main project documentation.