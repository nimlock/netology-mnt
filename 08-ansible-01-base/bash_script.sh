#!/usr/bin/env bash

set -e

docker-compose up -d
ansible-playbook -i playbook/inventory/prod.yml --vault-password-file=./.vault.py -v playbook/site.yml
docker-compose down -t 1
