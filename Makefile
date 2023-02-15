# Makefile for go-faas-t

default: all

# Apply infrastructure changes
all:
	terraform apply -auto-approve

build:
	$(MAKE) consumer
	$(MAKE) producer

producer:
	docker build src/producer -t go-faas-producer

consumer:
	faas-cli build consumer

deploy:
	kind load docker-image go-faas-consumer:latest --name kind-faas
	kind load docker-image go-faas-producer --name kind-faas
	kubectl apply -Rf ./kubernetes
	kubectl rollout restart deployment producer
	faas-cli deploy consumer

# authenticate with the faas cli based on the default user secret in k8s
faas-login:
	faas-cli login \
		--username $$(kubectl get secret basic-auth -n openfaas -o json | jq -r '.data | map_values(@base64d) | .["basic-auth-user"]') \
		--password $$(kubectl get secret basic-auth -n openfaas -o json | jq -r '.data | map_values(@base64d) | .["basic-auth-password"]') \
		--gateway http://127.0.0.1:6969

# Export kind cluster kubeconfig
kubeconfig:
	kind export kubeconfig --name kind-faas

# Remove cluster and terraform state
clean:
	kind delete cluster --name kind-faas
	rm terraform.tfstate*

.PHONY: all build consumer producer deploy faas-login kubeconfig
