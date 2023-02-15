# go-faas-t

## Overview

Just a playground for watching services scale to meet demand, with a bunch of DevOps goodies thrown in. Great opportunity
to learn more about the self-hosted functions as a service.

WIP: A backend service receives / retrieves different images from a remote URI. It pushes the image data onto a message queue,
storing the message / job id in redis in order to reference the state of the job later. A serverless process receives 
the message and resizes the image, then pops it back into redis for persistent storage (For simplicities sake). 
Hopefully, there might come a UI to tie it all in together?

### TODO

Everything!

- [x] Create a backend service that retrieves images from a data source.
- [x] Enable data push to a RabbitMQ.
  - This simply grabs a URL and puts it on the queue, but it will suffice for a demo :-) 
- [] Enable job id persistence in Redis.
- [] Create a function that is triggered on message creation in RabbitMQ.
- [] Enable function to push resized image to Redis.
- [] Create UI to display job progress.
    - TODO: Add steps as this is undertaken.

## Requirements

- [Terraform](https://www.terraform.io/)
- [Docker](https://www.docker.com/)
- [kind](https://kind.sigs.k8s.io/)
- [OpenFaaS](https://docs.openfaas.com/cli/install/)
- [jq](https://stedolan.github.io/jq/)
- [Helm](https://helm.sh/docs/intro/install/)

## Quickstart

Use the following makefile directives to bring the stack up quickly.

```bash
make          # Bring up a kind cluster with rabbit, faas, and connector.
make build    # Build the consumer and producer applications
make deploy   # Push apps and config to Kubernetes
````

You may need to setup your `.kubeconfig` file to talk to the kind cluster, and `faas-cli` will
require a login once the gateway is forwarded locally. 

To export cluster credentials to your kubeconfig file run:

```bash
make kubeconfig
```

To forward the FaaS gateway and authenticate with the default token run:

```bash
kubectl port-forward -n openfaas svc/gateway 6969:8080 &
make faas-login
```

## Credentials

Throughout this example the default credentials for each service are used widely.

These can be found in the following Kubernetes secrets, and will differ on each install.

### OpenFaas

```bash
kubectl get secret basic-auth -n openfaas -o json | jq -r '.data | map_values(@base64d)'
{
  "basic-auth-password": "uiikDojwnzFA",
  "basic-auth-user": "admin"
}
```

### RabbitMQ

```bash
kubectl get secret rabbitmq-default-user -n default -o json | jq -r '.data | map_values(@base64d)'
{
  "default_user.conf": "default_user = default_user_0T58DCWQFcWQbLrv3hy\ndefault_pass = b2aC2VCipg608CN76_qjw4cMrB5_dSkY\n",
  "host": "rabbitmq.default.svc",
  "password": "b2aC2VCipg608CN76_qjw4cMrB5_dSkY",
  "port": "5672",
  "provider": "rabbitmq",
  "type": "rabbitmq",
  "username": "default_user_0T58DCWQFcWQbLrv3hy"
}
```


## Services

- [rabbitmq/amqp091-go](https://github.com/rabbitmq/amqp091-go)
- [go-redis/redis](https://github.com/go-redis/redis)

## Infrastructure

- [Open FaaS](https://github.com/openfaas/faas-netes/blob/master/chart/openfaas/README.md)
    - [RabbitMQ Connector](https://github.com/Templum/rabbitmq-connector)
- [Redis](https://github.com/redis/redis)
- [ingress-nginx](https://github.com/kubernetes/ingress-nginx/)
- [RabbitMQ](https://github.com/rabbitmq/rabbitmq-server)
