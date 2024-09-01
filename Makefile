fmt:
	terraform fmt --recursive ./*.tf

apply:
	terraform apply --auto-approve

destroy:
	terraform destroy --auto-approve