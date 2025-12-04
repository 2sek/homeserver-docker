#!/bin/bash

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_help() {
printf "${BLUE}============================================================${NC}\n"
printf "${YELLOW}                  HomeServer Management Script              ${NC}\n"
printf "${BLUE}============================================================${NC}\n\n"
printf "${GREEN}Usage:${NC}\n"
printf "  ${YELLOW}./homeserver help${NC}             → Show available commands\n"
printf "  ${YELLOW}./homeserver update${NC}           → Update only docker stacks with currently running services\n"
printf "  ${YELLOW}./homeserver update all${NC}       → Update and start all docker stacks regardless of running state\n"
printf "  ${YELLOW}./homeserver stop${NC}             → Stop all cdocker stacks\n"
printf "  ${YELLOW}./homeserver stop <dir>${NC}       → Stop a single stack\n"
printf "  ${YELLOW}./homeserver start <dir>${NC}      → Start a single stack\n"
}

find_compose_dirs() {
  find . -mindepth 2 -maxdepth 2 -name "docker-compose.yml" -exec dirname {} \; | sort -u
}

is_stack_running() {
  local compose_file="$1/docker-compose.yml"
  docker compose -f "$compose_file" ps --services --filter "status=running" | grep -q .
}

update_stack() {
  local dir="$1"
  local compose_file="$dir/docker-compose.yml"
  echo -e "${YELLOW}Updating stack in $dir...${NC}"
  docker compose -f "$compose_file" up -d --pull always --force-recreate
}

stop_stack() {
  local dir="$1"
  local compose_file="$dir/docker-compose.yml"
  echo -e "${RED}Stopping stack in $dir...${NC}"
  docker compose -f "$compose_file" down
}

start_stack() {
  local dir="$1"
  local compose_file="$dir/docker-compose.yml"
  echo -e "${GREEN}Starting stack in $dir...${NC}"
  docker compose -f "$compose_file" up -d
}

create_traefik_proxy_network() {
  if ! docker network inspect traefik_proxy >/dev/null 2>&1; then
    echo -e "${BLUE}Network 'traefik_proxy' does not exist. Creating it...${NC}"
    docker network create traefik_proxy
  fi
}

# --- Main Script ---

COMMAND="$1"
OPTION="$2"

case "$COMMAND" in
  help)
    show_help
    ;;
  update)
    UPDATE_ALL=false
    [[ "$OPTION" == "all" ]] && UPDATE_ALL=true

    create_traefik_proxy_network

    for dir in $(find_compose_dirs); do
      if ! $UPDATE_ALL; then
        if is_stack_running "$dir"; then
          update_stack "$dir"
        else
          echo -e "${BLUE}Skipping $dir (no running services)${NC}"
        fi
      else
        update_stack "$dir"
      fi
    done

    echo -e "${GREEN}Selected docker-compose stacks updated.${NC}"
    ;;
  stop)
    if [[ -n "$OPTION" ]]; then
      stop_stack "$OPTION"
    else
      for dir in $(find_compose_dirs); do
        stop_stack "$dir"
      done
      echo -e "${RED}All stacks stopped.${NC}"
    fi
    ;;
  start)
    if [[ -n "$OPTION" ]]; then
      start_stack "$OPTION"
    else
      echo -e "${RED}Please specify a service directory to start.${NC}"
    fi
    ;;
  *)
    echo -e "${RED}Unknown command: $COMMAND${NC}"
    echo -e "${RED}Run './homeserver help' for usage.${NC}"
    ;;
esac
