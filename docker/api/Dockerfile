FROM php:8.4-apache

COPY ../../apps/api /var/www/html/api

COPY docker/api/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
