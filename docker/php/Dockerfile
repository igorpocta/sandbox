FROM php:8.2.11-fpm AS app_base

ARG TIMEZONE=Europe/Prague
ENV TIMEZONE=${TIMEZONE}

# Set timezone
RUN ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
	echo ${TIMEZONE} > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    bash \
    zip \
    unzip \
    cron \
    vim \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    zlib1g-dev \
    libwebp-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libzip-dev \
    libbz2-dev

RUN docker-php-ext-configure zip && \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install pdo_mysql mysqli soap xml bz2 zip mbstring exif pcntl bcmath gd intl && \
    apt-get clean -y && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# PHP Customization
ADD ./docker/php/php.ini /usr/local/etc/php/conf.d/custom-php.ini
ADD ./docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini


WORKDIR /var/www/html



# Pre-production image (for production and development)
FROM app_base as app_pre_production

ENV COMPOSER_ALLOW_SUPERUSER=1

COPY --chown=www-data:www-data ./ /var/www/html
COPY ./docker/php/docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
RUN chmod +x /usr/local/bin/docker-php-entrypoint

# Composer - install dependencies
RUN set -eux;
RUN composer install --optimize-autoloader --no-interaction --no-progress --no-dev



# Production image
FROM app_pre_production as app_production

COPY --chown=www-data:www-data / /var/www/html

ENTRYPOINT [ "/usr/local/bin/docker-php-entrypoint" ]

CMD ["php-fpm"]



# Production image with cron
FROM app_production AS app_cron

USER root

# Adding crontab to the appropriate location
COPY ./config/crontab.ini /etc/crontab.ini

# Giving permission to crontab file
RUN chmod 0644 /etc/crontab.ini

# Running crontab
RUN crontab -u www-data /etc/crontab.ini

# Creating entry point for cron
ENTRYPOINT ["cron", "-f", "-L /dev/stdout"]



# Development image
FROM app_base as app_development

# Install XDebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# FILES (it overrides originals)
ADD ./docker/php/dev/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
ADD ./docker/php/dev/error_reporting.ini /usr/local/etc/php/conf.d/error_reporting.ini

ARG USER_ID
ARG GROUP_ID

# Create a non-root user
RUN groupadd -g ${GROUP_ID} appuser && \
    useradd -l -u ${USER_ID} -g appuser appuser && \
    install -d -m 0755 -o appuser -g appuser /home/appuser

# Set working directory and ownership
RUN chown -R appuser:appuser /var/www/html
USER appuser

