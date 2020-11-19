#!/usr/bin/env bash

ACTION="$1"
if [ "${ACTION}" = "start" ]; then
  DOCKER_CMD="up -d"
else
  DOCKER_CMD="down"
fi

if [ "${STACK}" = "all" ]; then
  docker-compose \
    -f docker-compose.override.logging.yml \
    -f docker-compose.override.prometheus-server.yml \
    -f docker-compose.override.prometheus-exporters.yml \
    $DOCKER_CMD
elif [ "${STACK}" = "prometheus" ]; then
  docker-compose \
    -f docker-compose.override.prometheus-server.yml \
    -f docker-compose.override.prometheus-exporters.yml \
    $DOCKER_CMD
else
  docker-compose $DOCKER_CMD
fi

