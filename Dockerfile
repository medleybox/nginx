FROM nginx:mainline-alpine
ENV APP_ENV prod

RUN touch /etc/nginx/proxy.conf; mkdir -p /etc/nginx/bin/;

COPY nginx.conf frontend_localhost_service.conf app.key app.pem /etc/nginx/
COPY entrypoint.sh inject-config wait-for-service /etc/nginx/bin/
RUN chmod +x /etc/nginx/bin/*

COPY --from=ghcr.io/medleybox/webapp:master /var/www/public /var/www/public
COPY --from=ghcr.io/medleybox/frontend:master /app/dist /var/www/public

EXPOSE 80
EXPOSE 443

STOPSIGNAL SIGTERM

ENTRYPOINT ["/etc/nginx/bin/entrypoint.sh"]

HEALTHCHECK --interval=60s --timeout=1s CMD curl -k -f https://127.0.0.1/api/healthcheck || exit 1
