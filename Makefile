TERRAFORMCMD=/opt/homebrew/bin/terraform
TERRAFORMINIT=$(TERRAFORMCMD) init
TERRAFORMFMT=$(TERRAFORMCMD) fmt
TERRAFORMPLAN=$(TERRAFORMCMD) plan
TERRAFORMAPPLY=$(TERRAFORMCMD) apply -auto-approve
TERRAFORMDESTROY=$(TERRAFORMCMD) destroy -auto-approve

init:
	saml2aws login --force

init-backend:
	cd `pwd`/terraform-init-backend/ && $(TERRAFORMINIT)
	cd `pwd`/terraform-init-backend/ && $(TERRAFORMAPPLY)

init-main:
	cd `pwd`/terraform/ && $(TERRAFORMINIT)

apply: plan
	cd `pwd`/terraform/ && $(TERRAFORMAPPLY) ../tmp/plan.out
	rm -f `pwd`/tmp/plan.out

plan: fmt
	rm -f `pwd`/tmp/plan.out
	cd `pwd`/terraform/ && $(TERRAFORMPLAN) -var-file ../variables/terraform.tfvars -out=../tmp/plan.out

clean:
	rm -f `pwd`/tmp/plan.out

clean-all:
	find `pwd` -type d -iname ".terraform" -exec rm -rf {} \;
	find `pwd` -type f -iname ".terraform.lock.hcl" -delete

destroy-main:
	cd `pwd`/terraform/ && $(TERRAFORMDESTROY)

destroy-backend:
	cd `pwd`/terraform-init-backend/ && $(TERRAFORMDESTROY)

destroy-all: destroy-main destroy-backed

fmt:
	cd `pwd`/terraform-init-backend/ && $(TERRAFORMFMT)
	cd `pwd`/terraform/ && $(TERRAFORMFMT)