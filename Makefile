.PHONY: inventory


default: plan

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