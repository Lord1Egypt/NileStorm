FROM php:8.3-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    mysqli \
    pdo \
    pdo_mysql \
    zip

# Enable Apache modules and allow .htaccess overrides
RUN a2enmod rewrite headers \
    && sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

WORKDIR /var/www/html

# Copy application code (excludes files in .dockerignore)
COPY . /var/www/html/

# Create runtime-writable directories and set permissions
RUN mkdir -p var/log var/db GameEngine/Prevention GameEngine/Notes \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 var/ GameEngine/Prevention GameEngine/Notes

EXPOSE 80

CMD ["apache2-foreground"]
