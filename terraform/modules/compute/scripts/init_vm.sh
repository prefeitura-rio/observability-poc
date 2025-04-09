#!/usr/bin/env bash

ENDPOINT="https://raw.githubusercontent.com/prefeitura-rio/observability-poc/refs/heads/master/terraform/modules/compute"
UBUNTU_CODENAME=jammy
MAIN_DIR="/poc"
FILES=(
    "ansible/playbook.yaml"
    "ansible/requirements.yaml"
    "docker/gatus.yaml"
    "docker/traefik.yaml"
)

sudo mkdir -p "$MAIN_DIR"

for file in "${FILES[@]}"; do
    dest=$(basename "$file")
    curl -o "$MAIN_DIR/$dest" "$ENDPOINT/$file"
done


wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/ansible.list

sudo apt update && sudo apt install ansible

ansible-galaxy install -r "$MAIN_DIR"/requirements.yaml

ansible-playbook "$MAIN_DIR"/playbook.yaml
