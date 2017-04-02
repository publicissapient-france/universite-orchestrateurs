default: plan

show:
	cd terraform; terraform show

apply:
	cd terraform; terraform apply

plan:
	cd terraform; terraform plan

inventory::
	@mkdir -p ssh
	./scripts/terraform2ansible.js terraform/terraform.tfstate inventory/00_hosts

provision: inventory
	ansible-playbook provisioning/playbook.yml

destroy:
	cd terraform; terraform destroy

info:
	./scripts/terraform2ansible.js terraform/terraform.tfstate

get:
	@mkdir -p ssh
	@aws s3 cp s3://xebia-terraform-states/universite-orcherstrateur/terraform.tfstate   terraform/terraform.tfstate
	@aws s3 cp s3://xebia-terraform-states/universite-orcherstrateur/mesos-starter       ssh/mesos-starter
	@aws s3 cp s3://xebia-terraform-states/universite-orcherstrateur/mesos-starter.pub   ssh/mesos-starter.pub
	chmod 600 ssh/mesos-starter

push:
	@aws s3 cp terraform/terraform.tfstate   s3://xebia-terraform-states/universite-orcherstrateur/
	@aws s3 cp ssh/mesos-starter             s3://xebia-terraform-states/universite-orcherstrateur/
	@aws s3 cp ssh/mesos-starter.pub         s3://xebia-terraform-states/universite-orcherstrateur/

sshadd:
	ssh-add -k ./ssh/mesos-starter

nuke:
	find . -name '*.retry' -delete
	rm -rf ./ssh/
