#!/bin/bash
# Restarts and updates containers.

for dir in $(find . -mindepth 1 -maxdepth 1 -type d -not -path '.*');
do
  if [[ -n docker-compose.yaml ]]; then
    cd $dir
    echo $dir
    docker compose stop
    docker compose up -d
    cd ..
  fi;
done