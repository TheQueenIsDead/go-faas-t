# Makefile for go-scale

default: all

# Apply infrastructure changes
all:
	terraform apply -auto-approve

# Remove cluster and terraform state
clean:
	kind delete cluster --name kind-faas
	rm terraform.tfstate*

#images:
#	docker build consumer -t go-scale/consumer
#	docker build consumer -t go-scale/consumer


.PHONY: clean all
