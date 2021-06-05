TERRAFORMCMD=/opt/homebrew/bin/terraform

init:
	saml2aws login --force

init-backend:
	cd `pwd`/terraform-init-backend/ && $(TERRAFORMCMD) init
	cd `pwd`/terraform-init-backend/ && $(TERRAFORMCMD) apply -auto-approve

init-main:
	cd `pwd`/terraform/ && $(TERRAFORMCMD) init

apply: plan
	cd `pwd`/terraform/ && $(TERRAFORMCMD) apply -auto-approve ../tmp/plan.out
	rm -f `pwd`/tmp/plan.out

plan:
	rm -f `pwd`/tmp/plan.out
	cd `pwd`/terraform/ && $(TERRAFORMCMD) plan -var-file ../variables/terraform.tfvars -out=../tmp/plan.out

clean:
	rm -f `pwd`/tmp/plan.out

clean-all:
	find `pwd` -type d -iname ".terraform" -exec rm -rf {} \;
	find `pwd` -type f -iname ".terraform.lock.hcl" -delete