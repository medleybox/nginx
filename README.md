# nginx
Nginx docker image used to run Medleybox.

## Workflow
A github action has been setup to automatically build and push the docker image within this repo when commits are pushed.

## Build
docker build -t ghcr.io/medleybox/nginx .

## Push
docker ghcr.io/medleybox/nginx