
default: all

# Bring the stack up or down with `all` or `destroy`
all: cluster infrastructure

destroy:
	kind delete cluster
	rm terraform.tfstate*

cluster:
	kind create cluster

images:
	docker build consumer -t go-scale/consumer
	docker build consumer -t go-scale/consumer


crd:
	# TODO: Try this! https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/kubectl_path_documents
	# https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx
	kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
	# Rabbit
	kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"


inf: infrastructure
infrastructure:
	terraform apply -auto-approve


.PHONY: cluster
