#!/usr/bin/env bash

SERVICE_ACCOUNT_KEY='${service_account_key}'
SERVICE_ACCOUNT_EMAIL='${service_account_email}'
GCE_PROJECT='${gce_project}'
ENDPOINT="https://raw.githubusercontent.com/prefeitura-rio/observability-poc/refs/heads/master/terraform/modules/compute"
MAIN_DIR="/poc"

export SERVICE_ACCOUNT_KEY
export SERVICE_ACCOUNT_EMAIL
export GCE_PROJECT

wait_for_apt() {
    while fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        echo "Waiting for apt locks to be released..."
        sleep 5
    done
}

sudo mkdir -p "$MAIN_DIR"

sudo curl "$ENDPOINT/ansible/playbook.yaml" -o "$MAIN_DIR/playbook.yaml"
sudo curl "$ENDPOINT/ansible/requirements.yaml" -o "$MAIN_DIR/requirements.yaml"
sudo curl "$ENDPOINT/docker/docker-compose.yaml" -o "$MAIN_DIR/docker-compose.yaml"
sudo curl "$ENDPOINT/docker/gatus.yaml" -o "$MAIN_DIR/gatus.yaml"
sudo curl "$ENDPOINT/docker/grafana.ini" -o "$MAIN_DIR/grafana.ini"

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

unset SERVICE_ACCOUNT_KEY
unset SERVICE_ACCOUNT_EMAIL
unset GCE_PROJECT
