# Makefile for go-faas-t

default: all

# Apply infrastructure changes
all:
	terraform apply -auto-approve

build:
	$(MAKE) consumer
	$(MAKE) producer

deploy:
	kind load docker-image go-faas-consumer --name kind-faas
	kind load docker-image go-faas-producer --name kind-faas
	kubectl apply -Rf ./kubernetes

# Export kind cluster kubeconfig
kubeconfig:
	kind export kubeconfig --name kind-faas

consumer:
	docker build src/consumer -t go-faas-consumer

producer:
	docker build src/producer -t go-faas-producer

# Remove cluster and terraform state
clean:
	kind delete cluster --name kind-faas
	rm terraform.tfstate*

#images:
#	docker build consumer -t go-faas-t/consumer
#	docker build consumer -t go-faas-t/consumer


.PHONY: clean all
