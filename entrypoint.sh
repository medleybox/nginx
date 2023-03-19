#!/bin/sh

ENCORE_PORT=${ENCORE_PORT:-443}
ENCORE_SERVICE=${ENCORE_SERVICE:-encore}

FRONTEND_PORT=${FRONTEND_PORT:-443}
FRONTEND_SERVICE=${FRONTEND_SERVICE:-frontend}

MAILHOG_PORT=${MAILHOG_PORT:-8025}
MAILHOG_SERVICE=${MAILHOG_SERVICE:-mailhog}

CODER_PORT=${CODER_PORT:-8080}
CODER_SERVICE=${CODER_SERVICE:-coder}

PGADMIN_PORT=${PGADMIN_PORT:-80}
PGADMIN_SERVICE=${PGADMIN_SERVICE:-pgadmin}

# Reset the proxy and localhost config
echo "" > /etc/nginx/proxy.conf
echo "" > /etc/nginx/localhost.conf

nginx -v
if [ "${APP_ENV}" == "prod" ]; then
    nginx -c /etc/nginx/nginx.conf;
    exit 0;
fi;

for I in $SERVICES
do
  eval "SERVICE=\${${I}_SERVICE}"
  echo $SERVICE

  eval "PORT=\${${I}_PORT}"
  echo $PORT

  /etc/nginx/bin/wait-for-service $SERVICE $PORT
done

echo "proxy.conf:"
cat /etc/nginx/proxy.conf;

nginx -c /etc/nginx/nginx.conf
