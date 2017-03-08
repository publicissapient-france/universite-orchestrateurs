# Orchestration de conteneurs : le choix des armes !

## Commandes utiles

- `make info` affiche les machines démarées
- `make plan` teste la configuration terraform
- `make apply` applique la recette terraform
- `make provision` provisionne les machines avec ansible en passant par le bastion

## Connection ssh 

- `ssh-add -K <key>` pour ajouter la clé au ssh-agent

## Prérequis

Le cli aws est requis pour télécharger la clé ssh et le terraform.state depuis s3 :
- `pip install awscli` pour install le cli aws
- `aws configure` pour configurer le cli
- `make get` pour télécharger les fichiers

## Rôles ansible

- `ansible-galaxy install williamyeh.prometheus`