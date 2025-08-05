#!/bin/bash
set -e

echo "PrivateBin Production Environment Starting..."

# Set up configuration if not exists
if [ ! -f /var/www/html/cfg/conf.php ]; then
    echo "Creating production configuration..."
    cp /var/www/html/cfg/conf.sample.php /var/www/html/cfg/conf.php
    
    # Configure for production based on environment variables
    if [ -n "$PRIVATEBIN_DATA_PATH" ]; then
        sed -i "s|dir = PATH . \"data\"|dir = \"$PRIVATEBIN_DATA_PATH\"|" /var/www/html/cfg/conf.php
    fi
    
    if [ -n "$PRIVATEBIN_NAME" ]; then
        sed -i "s/; name = \"PrivateBin\"/name = \"$PRIVATEBIN_NAME\"/" /var/www/html/cfg/conf.php
    fi
    
    if [ -n "$PRIVATEBIN_BASEPATH" ]; then
        sed -i "s|; basepath = \"https://privatebin.example.com/\"|basepath = \"$PRIVATEBIN_BASEPATH\"|" /var/www/html/cfg/conf.php
    fi
    
    # Database configuration
    if [ -n "$PRIVATEBIN_DB_TYPE" ]; then
        echo "" >> /var/www/html/cfg/conf.php
        echo "[model]" >> /var/www/html/cfg/conf.php
        echo "class = Database" >> /var/www/html/cfg/conf.php
        echo "" >> /var/www/html/cfg/conf.php
        echo "[model_options]" >> /var/www/html/cfg/conf.php
        echo "dsn = \"${PRIVATEBIN_DB_TYPE}:host=${PRIVATEBIN_DB_HOST:-localhost};dbname=${PRIVATEBIN_DB_NAME:-privatebin}\"" >> /var/www/html/cfg/conf.php
        echo "username = \"${PRIVATEBIN_DB_USER:-privatebin}\"" >> /var/www/html/cfg/conf.php
        echo "password = \"${PRIVATEBIN_DB_PASS}\"" >> /var/www/html/cfg/conf.php
        echo "prefix = \"${PRIVATEBIN_DB_PREFIX:-pb_}\"" >> /var/www/html/cfg/conf.php
    fi
    
    echo "Production configuration created successfully."
fi

# Create data directory if using filesystem storage
if [ ! -d /var/www/html/data ]; then
    echo "Creating data directory..."
    mkdir -p /var/www/html/data
fi

# Set proper permissions for production
chown -R privatebin:privatebin /var/www/html/data /var/www/html/cfg
chmod -R 750 /var/www/html/data /var/www/html/cfg

# Validate configuration
echo "Validating configuration..."
php -f /var/www/html/bin/configuration-test-generator > /dev/null 2>&1 || {
    echo "Configuration validation failed. Please check your settings."
    exit 1
}

echo "Starting Apache server..."
echo "PrivateBin production environment ready!"

exec "$@"