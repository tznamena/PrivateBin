# PrivateBin Docker Development Environment Plan

## Project Analysis

### Main Components Overview

**PrivateBin** is a minimalist, open-source online pastebin where the server has zero knowledge of stored data. Data is encrypted/decrypted in the browser using 256-bit AES in Galois Counter mode (GCM).

#### Core Components:

1. **Backend (PHP)**
   - **Entry Point**: `index.php` - Main application controller
   - **Core Library**: `lib/` directory containing:
     - `Controller.php` - Main application controller (566 lines)
     - `Configuration.php` - Configuration management (313 lines)
     - `View.php` - Template rendering
     - `I18n.php` - Internationalization support
     - `Request.php` - HTTP request handling
     - `Model.php` - Data model abstraction

2. **Data Storage Backends** (`lib/Data/`):
   - `Filesystem.php` - File-based storage (default)
   - `Database.php` - SQL database storage (PDO-based)
   - `S3Storage.php` - AWS S3/CEPH RadosGW compatible storage
   - `GoogleCloudStorage.php` - Google Cloud Storage backend

3. **Frontend Components**:
   - **Templates**: `tpl/` directory with Bootstrap-based themes
     - `bootstrap5.php` (26KB, 544 lines) - Default modern template
     - `bootstrap.php` (27KB, 686 lines) - Legacy Bootstrap template
   - **JavaScript**: `js/` directory containing:
     - `privatebin.js` (186KB, 5970 lines) - Main application logic
     - `legacy.js` (8.1KB, 299 lines) - Legacy browser support
     - External libraries: jQuery, Bootstrap, Showdown, Purify, etc.
   - **Assets**: `css/`, `img/` directories for styling and images

4. **Configuration**:
   - `cfg/conf.sample.php` - Configuration template
   - Supports file uploads, discussions, password protection, expiration times
   - Multiple storage backend options
   - Template selection and theming

5. **Internationalization**:
   - `i18n/` directory with translation files
   - Automatic browser language detection

6. **Testing Infrastructure**:
   - **PHP Tests**: `tst/` directory with PHPUnit tests
   - **JavaScript Tests**: `js/test/` with Mocha tests
   - Existing Docker testing image: `privatebin/unit-testing`

### System Requirements

#### Minimal Requirements:
- PHP 7.4+ (current: supports up to PHP 8.x)
- PHP zlib extension (mandatory)
- Web server with JavaScript-enabled browser support
- Write permissions for data directory

#### Optional Requirements:
- PHP GD extension (for identicon/vizhash icons)
- Database (MySQL, PostgreSQL, SQLite) with PDO support
- S3-compatible storage or Google Cloud Storage
- WebAssembly support in browsers

#### Current Development Setup:
- Uses `.devcontainer/` for VS Code development containers
- Existing `Makefile` with comprehensive build targets
- Composer for PHP dependency management
- NPM for JavaScript testing dependencies

## Docker Development Environment Plan

### 1. Dockerfile Strategy

#### Multi-stage Dockerfile approach:
1. **Base Stage**: PHP 8.2-apache with required extensions
2. **Dependencies Stage**: Install Composer and NPM dependencies
3. **Development Stage**: Include development tools and testing frameworks
4. **Production Stage**: Optimized runtime image

#### Key considerations:
- Use official PHP Apache image as base
- Install required PHP extensions: `zlib`, `gd`, `pdo`, `pdo_sqlite`, `pdo_mysql`
- Configure Apache with proper document root and mod_rewrite
- Handle file permissions for data directory
- Support for multiple storage backends

### 2. Development Environment Features

#### Container Configuration:
- **Port Exposure**: 8080 (HTTP) for development
- **Volume Mounts**:
  - Source code: `/var/www/html` (bind mount for live development)
  - Data persistence: `/var/www/html/data` (named volume)
  - Configuration: `/var/www/html/cfg` (bind mount for config changes)
- **Environment Variables**:
  - `PRIVATEBIN_CONFIG_PATH` - Custom config file path
  - `PRIVATEBIN_DATA_PATH` - Custom data directory path
  - Database connection variables for testing

#### Development Tools Integration:
- Include Composer for PHP dependency management
- Include Node.js/NPM for JavaScript testing
- Install PHPUnit and Mocha testing frameworks
- Support for Xdebug for PHP debugging
- Include development utilities: git, vim, curl

### 3. Makefile Targets Enhancement

#### Proposed new targets to add to existing Makefile:

```makefile
# Docker Development Targets
docker-build: ## Build the development Docker image
docker-dev: ## Start development environment with live reload
docker-test: ## Run all tests in Docker container
docker-shell: ## Open shell in running development container
docker-clean: ## Clean up Docker containers and images
docker-prod: ## Build production Docker image
```

#### Integration with existing targets:
- Extend existing `test`, `coverage`, `doc` targets to work within Docker
- Maintain compatibility with current workflow
- Add Docker-specific configuration options

### 4. Development Workflow

#### Local Development Setup:
1. `make docker-build` - Build development image
2. `make docker-dev` - Start development server with live reload
3. `make docker-test` - Run test suite in container
4. `make docker-shell` - Access container for debugging

#### Configuration Management:
- Default configuration auto-generated from `cfg/conf.sample.php`
- Environment-specific overrides via Docker environment variables
- Support for external configuration files via volume mounts

#### Data Persistence:
- Development: Use filesystem backend with Docker volume
- Testing: Support for in-memory SQLite database
- Production-ready: Database and S3 storage backend examples

### 5. Storage Backend Support

#### Filesystem Storage (Default):
- Docker volume for `data/` directory
- Proper file permissions and ownership
- Backup and restore capabilities

#### Database Storage:
- Docker Compose with MySQL/PostgreSQL services
- Database initialization scripts
- Migration and backup procedures

#### External Storage:
- S3/MinIO integration examples
- Google Cloud Storage configuration
- Environment variable configuration patterns

### 6. Security Considerations

#### Container Security:
- Non-root user execution
- Read-only root filesystem where possible
- Minimal attack surface with distroless production images
- Secrets management for database credentials

#### Application Security:
- HTTPS-ready configuration
- Security headers configuration
- File upload restrictions and scanning
- Rate limiting and DDoS protection examples

### 7. Testing and Quality Assurance

#### Automated Testing:
- Integration with existing PHPUnit and Mocha test suites
- Docker-based CI/CD pipeline examples
- Code coverage reporting in containerized environment
- Linting and code quality checks

#### Performance Testing:
- Load testing setup with containerized tools
- Performance monitoring and profiling
- Resource usage optimization

### 8. Documentation and Examples

#### Developer Documentation:
- Quick start guide for Docker development
- Configuration examples for different use cases
- Troubleshooting guide for common Docker issues
- Performance tuning recommendations

#### Production Deployment:
- Docker Compose production examples
- Kubernetes deployment manifests
- Monitoring and logging configuration
- Backup and disaster recovery procedures

## Implementation Priority

### Phase 1: Basic Development Environment
1. Create multi-stage Dockerfile
2. Add basic Makefile targets
3. Implement development configuration
4. Test basic functionality

### Phase 2: Enhanced Development Features
1. Add testing integration
2. Implement database support
3. Add development tools and debugging
4. Create documentation

### Phase 3: Production Readiness
1. Optimize production Dockerfile
2. Add security hardening
3. Implement external storage backends
4. Create deployment examples

### Phase 4: Advanced Features
1. CI/CD integration
2. Monitoring and logging
3. Performance optimization
4. Advanced security features

## Success Criteria

- [ ] Developers can start coding with single `make docker-dev` command
- [ ] All existing tests pass in Docker environment
- [ ] Support for all storage backends (filesystem, database, S3, GCS)
- [ ] Production-ready container images
- [ ] Comprehensive documentation and examples
- [ ] Maintains compatibility with existing development workflow
- [ ] Secure and optimized for performance

This plan provides a comprehensive approach to creating a robust Docker development environment for PrivateBin while maintaining compatibility with the existing development workflow and supporting all the application's features and storage backends.