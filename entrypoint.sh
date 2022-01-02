#!/bin/sh

ENCORE_PORT=${ENCORE_PORT:-443}
ENCORE_SERVICE=${ENCORE_SERVICE:-encore}

MAILHOG_PORT=${MAILHOG_PORT:-8025}
MAILHOG_SERVICE=${MAILHOG_SERVICE:-mailhog}

nginx -v

# Wait for services to start up
sleep 5;

# Reset the proxy config
echo "" > /etc/nginx/proxy.conf

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

echo "proxy.conf:"
cat /etc/nginx/proxy.conf;

nginx -c /etc/nginx/nginx.conf