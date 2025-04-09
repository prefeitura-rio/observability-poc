#!/usr/bin/env bash

ENDPOINT="https://raw.githubusercontent.com/prefeitura-rio/observability-poc/refs/heads/master/terraform/modules/compute"

FILES=(
    "ansible/playbook.yaml"
    "ansible/requirements.yaml"
    "docker/gatus.yaml"
    "docker/traefik.yaml"
)

mkdir -p "$HOME"/poc

sudo apt-get update

sudo apt-get install -y python3 python3-pip

sudo pip3 install ansible

for file in "${FILES[@]}"; do
    dest=$(basename "$file")
    curl -o "$HOME/poc/$dest" "$ENDPOINT/$file"
done

ansible-galaxy install -r "$HOME"/poc/requirements.yaml

ansible-playbook "$HOME"/poc/playbook.yaml
