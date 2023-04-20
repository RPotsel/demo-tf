PROJECT?=demo-app
WORKSPACE?=dev

init-project:
	cd ./$(PROJECT) && ./prepare.sh init

tf-apply:
	cd ./$(PROJECT) && terraform apply tfplan

tf-plan:
	terraform -chdir=$(PROJECT) init -input=false --reconfigure
	terraform -chdir=$(PROJECT) workspace select $(WORKSPACE) || \
		terraform -chdir=$(PROJECT) workspace new $(WORKSPACE)
	terraform -chdir=$(PROJECT) plan -input=false -refresh -out=tfplan -var-file $(WORKSPACE).tfvars

tf-clean:
	terraform -chdir=$(PROJECT) plan -destroy -out=tfplan -var-file $(WORKSPACE).tfvars
