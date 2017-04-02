# Orchestration de conteneurs : le choix des armes !

## Commandes utiles

- `make info` affiche les machines démarées
- `make plan` teste la configuration terraform
- `make apply` applique la recette terraform
- `make provision` provisionne les machines avec ansible en passant par le bastion`

Utilitaires:
- `./uopen.js prometheus` ouvre l'url du service prometheus configuré dans **services.json**

## Connection ssh 

- `ssh-add -K <key>` pour ajouter la clé au ssh-agent

## Requirements

- Run `make get` to download the following files:
  - `terraform/terraform.tfstate`, le state de Terraform
  - `mesos-starter(.pub)`, the keypairs used to connect to instances

Run the following commands to setup `ansible` (used for deployments) and
`awscli` (used to download the SSH keypair and terraform.state from AWS S3):

    virtualenv --python=python2 venv
    source ./venv/bin/activate
    pip install -r requirements.txt

You'll also have to install `terraform` and probably `kubectl` from your OS
packages.

## Rôles ansible

- `ansible-galaxy install williamyeh.prometheus`
