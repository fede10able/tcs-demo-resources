.DEFAULT_GOAL := apply

LABKEY=./labkey

vars = -var "aws_key_pair_pub=$(LABKEY)"

init: $(LABKEY)
	terraform init

$(LABKEY): 
	ssh-keygen -b 2048 -t rsa -f $(LABKEY) -q -N ""

plan: *.tf init 
	terraform plan $(vars) -out plan.out

apply: plan
	terraform apply "plan.out"

destroy: 
	terraform destroy $(vars) -auto-approve

show: 
	terraform show 

clean: destroy
	rm -rf plan.out terraform.tfstate*

.PHONY: plan apply init destroy clean show
    