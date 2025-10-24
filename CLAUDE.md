# Claude AI Context: PrivateBin Project

This document provides essential context for Claude AI when working with the PrivateBin project. It contains project-specific information, conventions, and important details that should be considered in all interactions.

## Project Overview

**PrivateBin** is a minimalist, open-source online pastebin where the server has zero knowledge of stored data. Data is encrypted and decrypted in the browser using 256-bit AES in Galois Counter mode (GCM).

### Key Characteristics
- **Zero-knowledge**: Server never sees unencrypted data
- **Client-side encryption**: All encryption/decryption happens in the browser
- **Multiple storage backends**: Filesystem, Database (PDO), S3, Google Cloud Storage
- **Multi-language support**: Full internationalization
- **Security-focused**: End-to-end encryption, secure configurations
- **Self-hosted**: Designed for independent deployment

## Technical Stack

### Backend (PHP)
- **PHP Version**: 7.4+ (current development uses 8.2)
- **Framework**: Custom MVC architecture
- **Dependencies**: Managed via Composer
- **Key Libraries**:
  - `jdenticon/jdenticon`: Icon generation
  - `mlocati/ip-lib`: IP address handling
  - `symfony/polyfill-php80`: PHP compatibility
  - `yzalis/identicon`: User identicons

### Frontend (JavaScript)
- **Main Application**: `js/privatebin.js` (~6000 lines)
- **Legacy Support**: `js/legacy.js` for older browsers
- **Dependencies**: jQuery, Bootstrap, Showdown (Markdown), DOMPurify
- **Testing**: Mocha with NYC for coverage
- **Build Process**: No complex build system, direct file serving

### Storage Backends
1. **Filesystem** (default): File-based storage in `data/` directory
2. **Database**: PDO-compatible databases (MySQL, PostgreSQL, SQLite)
3. **S3Storage**: AWS S3 or S3-compatible (CEPH RadosGW)
4. **GoogleCloudStorage**: Google Cloud Storage integration

## Project Structure

```
PrivateBin/
├── index.php                 # Application entry point
├── lib/                      # Core PHP classes
│   ├── Controller.php        # Main application controller
│   ├── Configuration.php     # Configuration management
│   ├── View.php             # Template rendering
│   ├── I18n.php             # Internationalization
│   ├── Model/               # Data models
│   ├── Data/                # Storage backend implementations
│   └── Persistence/         # Data persistence classes
├── tpl/                     # HTML templates
│   ├── bootstrap5.php       # Default modern template
│   └── bootstrap.php        # Legacy template
├── js/                      # JavaScript files
│   ├── privatebin.js        # Main application logic
│   ├── legacy.js           # Legacy browser support
│   ├── test/               # JavaScript tests
│   └── package.json        # Node.js dependencies
├── css/                     # Stylesheets
├── cfg/                     # Configuration
│   └── conf.sample.php     # Configuration template
├── i18n/                    # Translation files
├── doc/                     # Documentation
├── tst/                     # PHP unit tests
├── composer.json           # PHP dependencies
├── Makefile               # Build and development commands
└── Docker files           # Container environment
```

## Development Environment

### Docker Setup (Recommended)
The project includes a comprehensive Docker development environment:

```bash
# Quick start
make docker-dev    # Starts all services
make docker-test   # Runs test suite
make docker-shell  # Opens container shell
make docker-logs   # Shows logs (30s timeout)
make docker-stop   # Stops environment
```

### Services Available
- **PrivateBin**: http://localhost:8080
- **Adminer** (DB admin): http://localhost:8081
- **MinIO Console**: http://localhost:9001
- **MySQL**: localhost:3306
- **Redis**: localhost:6379

### Traditional Setup
- PHP 7.4+ with extensions: zlib, gd, pdo
- Web server (Apache/Nginx) with rewrite support
- Database (optional): MySQL, PostgreSQL, SQLite
- Node.js (for JavaScript testing)

## Configuration System

### Main Configuration (`cfg/conf.php`)
Based on INI format with sections:
- `[main]`: Core application settings
- `[model]`: Storage backend selection
- `[model_options]`: Backend-specific configuration
- `[formatter_options]`: Text formatting options

### Important Settings
```ini
[main]
discussion = true              # Enable comments
password = true               # Enable password protection
fileupload = false           # File upload feature
sizelimit = 10000000         # Size limit in bytes
template = "bootstrap5"       # Default template

[model]
class = Filesystem           # Storage backend
```

## Testing Framework

### PHP Tests
- **Framework**: PHPUnit 9+
- **Location**: `tst/` directory
- **Coverage**: Xdebug integration
- **Command**: `make test-php` or `make docker-test-php`

### JavaScript Tests
- **Framework**: Mocha
- **Coverage**: NYC (Istanbul)
- **Location**: `js/test/`
- **Command**: `make test-js` or `make docker-test-js`

### Docker Testing
- **Integrated Environment**: All dependencies in containers
- **Command**: `make docker-test`
- **Benefits**: Consistent environment, all storage backends

## Code Quality Standards

### PHP Standards
- **PSR-4**: Autoloading standard
- **Namespace**: `PrivateBin\`
- **Code Style**: Custom (see `.php_cs`)
- **Documentation**: PHPDoc format

### JavaScript Standards
- **Linting**: ESLint with custom rules
- **Style**: Custom (see `.eslintrc`)
- **Testing**: Comprehensive unit tests

### Security Practices
- **Input Validation**: All user input sanitized
- **XSS Prevention**: DOMPurify for HTML sanitization
- **CSRF Protection**: Built-in token system
- **Content Security Policy**: Strict CSP headers

## Common Development Tasks

### Adding New Features
1. **Backend**: Add to `lib/` with proper namespace
2. **Frontend**: Extend `js/privatebin.js`
3. **Configuration**: Add options to `conf.sample.php`
4. **Templates**: Update templates in `tpl/`
5. **Tests**: Add comprehensive test coverage
6. **Documentation**: Update relevant docs

### Storage Backend Development
1. **Extend**: `PrivateBin\Data\AbstractData`
2. **Implement**: Required methods (`create`, `read`, `delete`, etc.)
3. **Configure**: Add configuration options
4. **Test**: All CRUD operations and edge cases

### Template Development
1. **Base**: Use existing templates as reference
2. **Structure**: PHP-based template system
3. **Assets**: Include CSS/JS in template
4. **Testing**: Test with all features enabled

## Important Conventions

### Naming Conventions
- **PHP Classes**: PascalCase (`Controller`, `DataModel`)
- **PHP Methods**: camelCase (`getData`, `setConfiguration`)
- **JavaScript Functions**: camelCase (`initApplication`, `handleSubmit`)
- **CSS Classes**: kebab-case (`btn-primary`, `paste-container`)

### File Organization
- **One class per file**: PHP classes in separate files
- **Logical grouping**: Related functionality together
- **Clear separation**: Frontend/backend code separation

### Error Handling
- **PHP**: Exception-based error handling
- **JavaScript**: Promise-based with proper error propagation
- **User Feedback**: Clear, actionable error messages

## Security Considerations

### Critical Security Features
- **Client-side encryption**: Never trust server with plaintext
- **Secure defaults**: Conservative default configuration
- **Input sanitization**: All user input validated/sanitized
- **Output encoding**: Proper encoding for all contexts
- **HTTPS enforcement**: Strong recommendation for production

### Sensitive Areas
- **Encryption/Decryption**: `js/privatebin.js` crypto functions
- **Data Storage**: All storage backend implementations
- **User Input**: Form handling and validation
- **Configuration**: Server-side configuration parsing

## Performance Considerations

### Frontend Performance
- **Lazy Loading**: Load resources as needed
- **Compression**: Gzip/Brotli for assets
- **Caching**: Proper cache headers
- **Minification**: Production asset optimization

### Backend Performance
- **Database Optimization**: Proper indexing for database backends
- **File System**: Efficient file organization for filesystem backend
- **Memory Usage**: Conservative memory limits
- **Caching**: Session and configuration caching

## Deployment Patterns

### Production Deployment
1. **Web Server**: Apache/Nginx with proper configuration
2. **PHP Configuration**: Production-optimized settings
3. **Storage**: External database recommended for scale
4. **Security**: HTTPS, security headers, proper file permissions
5. **Monitoring**: Health checks, log monitoring

### Docker Deployment
1. **Production Image**: Multi-stage optimized build
2. **Environment Variables**: Configuration via environment
3. **Volumes**: Data persistence and configuration
4. **Health Checks**: Built-in container health monitoring

## Troubleshooting Guide

### Common Issues
1. **Permission Errors**: Check `data/` directory permissions
2. **Database Connection**: Verify database credentials and connectivity
3. **JavaScript Errors**: Check browser console for crypto API support
4. **Template Issues**: Verify template selection in configuration

### Debug Information
- **PHP Errors**: Check web server error logs
- **JavaScript Errors**: Browser developer console
- **Configuration**: Use `bin/configuration-test-generator`
- **Storage Backend**: Test backend connectivity independently

## Integration Points

### External Services
- **S3 Storage**: AWS SDK for PHP integration
- **Google Cloud**: Google Cloud Storage client
- **Database**: PDO for database abstraction
- **YOURLS**: URL shortener integration

### API Endpoints
- **Create Paste**: POST to root with JSON payload
- **Read Paste**: GET with paste ID
- **Delete Paste**: DELETE with proper authentication
- **Comments**: POST/GET for discussion threads

## Contribution Guidelines

### Code Contributions
1. **Fork and Branch**: Create feature branches
2. **Tests**: Add comprehensive test coverage
3. **Documentation**: Update relevant documentation
4. **Standards**: Follow existing code style
5. **Security**: Consider security implications

### Issue Reporting
1. **Reproduction**: Provide minimal reproduction case
2. **Environment**: Include version and environment details
3. **Logs**: Attach relevant error logs
4. **Security**: Use responsible disclosure for security issues

## Version Information

### Current Version: 2.0.0
- **PHP Support**: 7.4 - 8.x
- **Browser Support**: Modern browsers with crypto API
- **Database Support**: MySQL 5.7+, PostgreSQL 9.6+, SQLite 3.x
- **Storage Options**: Filesystem, Database, S3, Google Cloud

### Upgrade Considerations
- **Configuration Changes**: Review configuration format changes
- **Database Migration**: Run migration scripts if applicable
- **Template Updates**: Check template compatibility
- **JavaScript Changes**: Verify browser compatibility

## Special Notes for Claude

### When Working on This Project:
1. **Security First**: Always consider security implications of changes
2. **Zero-Knowledge**: Respect the zero-knowledge principle
3. **Backward Compatibility**: Maintain compatibility when possible
4. **Test Coverage**: Ensure comprehensive testing
5. **Documentation**: Update documentation for any changes
6. **Cross-Platform**: Consider different deployment environments
7. **Performance**: Be mindful of performance implications
8. **Accessibility**: Consider accessibility in UI changes

### Avoid These Common Mistakes:
1. **Server-side Decryption**: Never decrypt data on server
2. **Logging Sensitive Data**: Don't log paste content or keys
3. **Hardcoded Credentials**: Use configuration for all credentials
4. **Unsafe Defaults**: Default to secure configurations
5. **Missing Validation**: Always validate and sanitize input
6. **Breaking Changes**: Avoid breaking existing installations

### Project Maintenance:
- **Regular Updates**: Keep dependencies updated
- **Security Patches**: Prioritize security fixes
- **Performance Monitoring**: Track performance regressions
- **User Feedback**: Consider user experience improvements
- **Documentation**: Keep documentation current and accurate

This context should be referenced for all development, debugging, and enhancement tasks related to the PrivateBin project.