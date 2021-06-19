FROM xigen/nginx
#FROM nginx:mainline-alpine
#FROM nginx:alpine

#WORKDIR /var/www

#COPY servers.conf /etc/nginx/conf/servers.conf
#COPY --from=medleybox/webapp:latest /app/public /var/www/public
#COPY --from=medleybox/webapp:latest /app/public /var/www/public

#RUN ls -alsh /var/www/public

RUN touch /etc/nginx/proxy.conf; mkdir -p /etc/nginx/bin/;

COPY nginx.conf app.key app.pem /etc/nginx/
COPY entrypoint.sh /etc/nginx/bin/
COPY inject-config /etc/nginx/bin/
RUN chmod +x /etc/nginx/bin/*

EXPOSE 80
EXPOSE 443

STOPSIGNAL SIGTERM

ENTRYPOINT ["/etc/nginx/bin/entrypoint.sh"]

HEALTHCHECK --interval=60s --timeout=1s CMD curl -k -f https://localhost/nginx-health || exit 1
