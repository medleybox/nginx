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

nginx -v
if [ "${APP_ENV}" == "prod" ]; then
    nginx -c /etc/nginx/nginx.conf;
    exit 0;
fi;

# Wait for services to start up
sleep 2;

# Reset the proxy config
echo "" > /etc/nginx/proxy.conf

echo "Checking for $MAILHOG_SERVICE service"
timeout 2 nc -zv $MAILHOG_SERVICE $MAILHOG_PORT &> /dev/null

if [ "$?" -eq "0" ]; then
    echo "Connection successfull to connect to $MAILHOG_SERVICE service"
    echo "Injecting config"

    export SERVICE=${MAILHOG_SERVICE}
    export PORT=${MAILHOG_PORT}

    /etc/nginx/bin/inject-config >> /etc/nginx/proxy.conf
else
    echo "Unable to connect to $MAILHOG_SERVICE service"
fi

echo "Checking for $CODER_SERVICE service"
timeout 2 nc -zv $CODER_SERVICE $CODER_PORT &> /dev/null

if [ "$?" -eq "0" ]; then
    echo "Connection successfull to connect to $CODER_SERVICE service"
    echo "Injecting config"

    export SERVICE=${CODER_SERVICE}
    export PORT=${CODER_PORT}

    /etc/nginx/bin/inject-config >> /etc/nginx/proxy.conf
else
    echo "Unable to connect to $CODER_SERVICE service"
fi

echo "Checking for $PGADMIN_SERVICE service"
timeout 2 nc -zv $PGADMIN_SERVICE $PGADMIN_PORT &> /dev/null

if [ "$?" -eq "0" ]; then
    echo "Connection successfull to connect to $PGADMIN_SERVICE service"
    echo "Injecting config"

    export SERVICE=${PGADMIN_SERVICE}
    export PORT=${PGADMIN_PORT}

    /etc/nginx/bin/inject-config >> /etc/nginx/proxy.conf
else
    echo "Unable to connect to $PGADMIN_SERVICE service"
fi

echo "Waiting for $FRONTEND_SERVICE service"
ATTEMPTS_LEFT_TO_REACH_DATABASE=40
until [ $ATTEMPTS_LEFT_TO_REACH_DATABASE -eq 0 ] || timeout 1 nc -zv $FRONTEND_SERVICE $FRONTEND_PORT &> /dev/null 2>&1; do
    sleep 1
    ATTEMPTS_LEFT_TO_REACH_DATABASE=$((ATTEMPTS_LEFT_TO_REACH_DATABASE-1))
    echo "Still waiting for $FRONTEND_SERVICE to be ready... $ATTEMPTS_LEFT_TO_REACH_DATABASE attempts left"
done

if [ $ATTEMPTS_LEFT_TO_REACH_DATABASE -eq 0 ]; then
    echo "Unable to connect to $FRONTEND_SERVICE service"
else
    echo "Connection successfull to connect to $FRONTEND_SERVICE service"
    echo "Injecting config"

    export SERVICE=${FRONTEND_SERVICE}
    export PORT=${FRONTEND_PORT}

    /etc/nginx/bin/inject-config >> /etc/nginx/proxy.conf
fi

echo "Checking for $ENCORE_SERVICE service"
timeout 2 nc -zv $ENCORE_SERVICE $ENCORE_PORT &> /dev/null

if [ "$?" -eq "0" ]; then
    echo "Connection successfull to connect to $ENCORE_SERVICE service"
    echo "Injecting config"

    export SERVICE=${ENCORE_SERVICE}
    export PORT=${ENCORE_PORT}

    /etc/nginx/bin/inject-config >> /etc/nginx/proxy.conf
else
    echo "Unable to connect to $ENCORE_SERVICE service"
fi

echo "proxy.conf:"
cat /etc/nginx/proxy.conf;

nginx -c /etc/nginx/nginx.conf
