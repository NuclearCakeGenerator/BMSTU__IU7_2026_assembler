#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
  echo "This setup script must be run as root"
  exit 1
fi

echo -e "${BLUE}INSTALLING DEPENDENCIES...${NC}"
apt update
apt upgrade -y
apt install -y nasm make gcc gdb libgtk-3-dev

echo -e "${BLUE}SETTING UP ENVIRONMENT...${NC}"
mkdir -p .vscode
cp samples/* .vscode/

echo -e "${GREEN}ALL DONE${NC}"
