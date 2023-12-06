.PHONY: init
init:
	terraform init -upgrade

.PHONY: reapply
reapply: destroy cluster

.PHONY: destroy
destroy:
	terraform destroy -target=null_resource.talos-cluster-up -auto-approve
	terraform destroy -auto-approve

.PHONY: cluster
cluster:
	terraform plan -target=null_resource.talos-cluster-up -out=cluster.tfplan
	terraform apply -auto-approve cluster.tfplan
	terraform apply -auto-approve
