.PHONY: inventory


default: plan

show:
	cd terraform; terraform show

apply:
	cd terraform; terraform apply

plan:
	cd terraform; terraform plan

inventory:
	./terraform2ansible.js terraform/terraform.tfstate inventory

provision: inventory
	ansible-playbook -i inventory provisionning/playbook.yml

destroy:
	cd terraform; terraform destroy

info:
	./terraform2ansible.js terraform/terraform.tfstate

get:
	aws s3 cp s3://xebia-terraform-states/universite-orcherstrateur/terraform.tfstate   terraform/terraform.tfstate
	aws s3 cp s3://xebia-terraform-states/universite-orcherstrateur/mesos-starter       mesos-starter
	aws s3 cp s3://xebia-terraform-states/universite-orcherstrateur/mesos-starter.pub   mesos-starter.pub
	chmod 600 mesos-starter

push:
	aws s3 cp terraform/terraform.tfstate   s3://xebia-terraform-states/universite-orcherstrateur/
	aws s3 cp mesos-starter                 s3://xebia-terraform-states/universite-orcherstrateur/
	aws s3 cp mesos-starter.pub             s3://xebia-terraform-states/universite-orcherstrateur/

