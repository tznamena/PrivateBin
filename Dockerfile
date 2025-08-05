# Multi-stage Dockerfile for PrivateBin development and production

# Base stage with PHP and required extensions
FROM php:8.2-apache as base

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    sqlite3 \
    libsqlite3-dev \
    git \
    unzip \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        zip \
        gd \
        pdo \
        pdo_sqlite \
        pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite headers

# Set working directory
WORKDIR /var/www/html

# Create non-root user for security
RUN groupadd -r privatebin && useradd -r -g privatebin privatebin

# Development stage
FROM base as development

# Install additional development tools
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    vim \
    less \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Xdebug for development
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Configure Xdebug
RUN echo "xdebug.mode=debug,coverage" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Configure PHP for development
RUN echo "memory_limit=512M" >> /usr/local/etc/php/conf.d/development.ini \
    && echo "upload_max_filesize=100M" >> /usr/local/etc/php/conf.d/development.ini \
    && echo "post_max_size=100M" >> /usr/local/etc/php/conf.d/development.ini \
    && echo "display_errors=On" >> /usr/local/etc/php/conf.d/development.ini \
    && echo "error_reporting=E_ALL" >> /usr/local/etc/php/conf.d/development.ini

# Set up Apache configuration for PrivateBin
COPY docker/apache/privatebin.conf /etc/apache2/sites-available/000-default.conf

# Copy entrypoint script
COPY docker/entrypoint-dev.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]

# Production stage
FROM base as production

# Install Composer for production
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configure PHP for production
RUN echo "memory_limit=256M" >> /usr/local/etc/php/conf.d/production.ini \
    && echo "upload_max_filesize=10M" >> /usr/local/etc/php/conf.d/production.ini \
    && echo "post_max_size=10M" >> /usr/local/etc/php/conf.d/production.ini \
    && echo "display_errors=Off" >> /usr/local/etc/php/conf.d/production.ini \
    && echo "log_errors=On" >> /usr/local/etc/php/conf.d/production.ini \
    && echo "expose_php=Off" >> /usr/local/etc/php/conf.d/production.ini

# Copy application files
COPY . /var/www/html/

# Install PHP dependencies (production only)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Set up configuration
RUN cp cfg/conf.sample.php cfg/conf.php

# Create data directory and set permissions
RUN mkdir -p data \
    && chown -R privatebin:privatebin /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 750 data cfg

# Set up Apache configuration
COPY docker/apache/privatebin-prod.conf /etc/apache2/sites-available/000-default.conf

# Copy production entrypoint
COPY docker/entrypoint-prod.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

EXPOSE 80
USER privatebin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]