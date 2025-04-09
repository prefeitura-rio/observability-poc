#!/usr/bin/env bash

ENDPOINT="https://raw.githubusercontent.com/prefeitura-rio/observability-poc/refs/heads/master/terraform/modules/compute"
MAIN_DIR="/poc"
FILES=(
    "ansible/playbook.yaml"
    "ansible/requirements.yaml"
    "docker/docker-compose.yaml"
    "docker/gatus.yaml"
    "docker/grafana.ini"
)


wait_for_apt() {
    while fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        echo "Waiting for apt locks to be released..."
        sleep 5
    done
}

sudo mkdir -p "$MAIN_DIR"

for file in "${FILES[@]}"; do
    dest=$(basename "$file")
    sudo curl -o "$MAIN_DIR/$dest" "$ENDPOINT/$file"
done

wait_for_apt
sudo apt-get update
wait_for_apt
sudo apt-get install software-properties-common --yes
wait_for_apt
sudo add-apt-repository ppa:ansible/ansible --update --yes
wait_for_apt
sudo apt-get install ansible --yes
wait_for_apt

ansible-galaxy install -r "$MAIN_DIR"/requirements.yaml
ansible-playbook "$MAIN_DIR"/playbook.yaml
