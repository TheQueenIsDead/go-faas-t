# go-faas-t

## Overview

Just a playground for watching services scale to meet demand, with a bunch of DevOps goodies thrown in

WIP: A backend service retrieves different images from a remote URI. It pushes the image data onto a message queue,
storing the message / job id in redis in order to reference the state of the job later. A process receives the message
and resizes them, then pops it back into redis (For simplicity). Hopefully, there will come a UI to tie it all in
together.

### TODO

Everything!

- [] Create a backend service that retrieves images from a data source.
- [] Enable data push to a RabbitMQ.
- [] Enable job id persistence in Redis.
- [] Create a function that is triggered on message creation in RabbitMQ.
- [] Enable function to push resized image to Redis.
- [] Create UI to display job progress.
    - TODO: Add steps as this is undertaken.

## Requirements

- [Terraform](https://www.terraform.io/)
- [Docker](https://www.docker.com/)
- [kind](https://kind.sigs.k8s.io/)

## Quickstart

```bash
make
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
