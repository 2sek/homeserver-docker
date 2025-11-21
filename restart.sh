#!/bin/bash

# Usage:
#   ./restart           -> update only stacks with currently running services
#   ./restart --all     -> update all stacks regardless of running state

# Find all directories that contain a docker-compose.yaml file
find_compose_dirs() {
  find . -mindepth 2 -maxdepth 2 -name "docker-compose.yml" -exec dirname {} \; | sort -u
}

# Check if a stack has any running services
stack_is_running() {
  local compose_file="$1/docker-compose.yml"
  docker compose -f "$compose_file" ps --services --filter "status=running" | grep -q .
}

# Update a stack (pull + recreate)
update_stack() {
  local compose_file="$1/docker-compose.yml"
  echo "Updating stack in $1..."
  docker compose -f "$compose_file" up -d --pull always --force-recreate
}

# --- Main Script ---

UPDATE_ALL=false
if [[ "$1" == "--all" ]]; then
  UPDATE_ALL=true
fi

for dir in $(find_compose_dirs); do
  if ! $UPDATE_ALL; then
    if stack_is_running "$dir"; then
      update_stack "$dir"
    else
      echo "Skipping $dir (no running services)"
    fi
  else
    update_stack "$dir"
  fi
done

echo "Selected docker-compose stacks updated."
