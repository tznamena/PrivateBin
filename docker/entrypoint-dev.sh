#!/bin/bash
set -e

echo "PrivateBin Development Environment Starting..."

# Set up configuration if not exists
if [ ! -f /var/www/html/cfg/conf.php ]; then
    echo "Creating development configuration..."
    cp /var/www/html/cfg/conf.sample.php /var/www/html/cfg/conf.php
    
    # Enable development-friendly settings
    sed -i 's/;discussion = true/discussion = true/' /var/www/html/cfg/conf.php
    sed -i 's/;password = true/password = true/' /var/www/html/cfg/conf.php
    sed -i 's/fileupload = false/fileupload = true/' /var/www/html/cfg/conf.php
    sed -i 's/;qrcode = true/qrcode = true/' /var/www/html/cfg/conf.php
    sed -i 's/;email = true/email = true/' /var/www/html/cfg/conf.php
    
    echo "Development configuration created successfully."
fi

# Create data directory if not exists
if [ ! -d /var/www/html/data ]; then
    echo "Creating data directory..."
    mkdir -p /var/www/html/data
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html/data /var/www/html/cfg
chmod -R 755 /var/www/html/data /var/www/html/cfg

# Install PHP dependencies if vendor directory doesn't exist or is empty
if [ ! -d /var/www/html/vendor ] || [ -z "$(ls -A /var/www/html/vendor 2>/dev/null)" ]; then
    echo "Installing PHP dependencies..."
    composer install --optimize-autoloader
fi

# Install Node.js dependencies for testing if package.json exists in js directory
if [ -f /var/www/html/js/package.json ]; then
    echo "Installing JavaScript dependencies..."
    cd /var/www/html/js
    npm install
    
    # Install additional development dependencies for testing
    echo "Installing additional JavaScript testing dependencies..."
    npm install --save-dev mocha@^10.0.0 nyc@^15.0.0
    cd /var/www/html
fi

# Install additional PHP development dependencies for comprehensive testing
echo "Installing additional PHP testing dependencies..."
composer require --dev google/cloud-storage aws/aws-sdk-php --ignore-platform-reqs --no-interaction

echo "Starting Apache server on port 8080..."
echo "PrivateBin development environment ready!"
echo "Access the application at: http://localhost:8080"
echo ""
echo "Development commands:"
echo "  make test        - Run all tests"
echo "  make coverage    - Generate coverage reports"
echo "  make doc         - Generate documentation"
echo ""

exec "$@"