FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

# Instalar extensões PHP necessárias
RUN apk add --no-cache \
    postgresql-dev \
    libzip-dev \
    zip \
    unzip \
    icu-dev \
    oniguruma-dev \
    git \
    curl \
    && docker-php-ext-install pdo pdo_pgsql pgsql zip bcmath intl opcache

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copiar composer.json e instalar dependências
COPY composer.json ./
RUN composer install --no-dev --no-interaction --optimize-autoloader

# Copiar aplicação
COPY . .

# Configurar permissões
RUN mkdir -p /var/www/html/bootstrap/cache \
    && mkdir -p /var/www/html/storage/framework/{cache,sessions,views} \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Variáveis de ambiente
ENV APP_ENV=production
ENV APP_DEBUG=false

# Expor porta
EXPOSE 8000

# Comando de início
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
