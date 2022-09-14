# CRD's
data "http" "ingress_crd" {
  url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
}
data "kubectl_file_documents" "ingress_crd" {
  content = data.http.ingress_crd.response_body
}
resource "kubectl_manifest" "ingress_crd" {
  for_each  = data.kubectl_file_documents.ingress_crd.manifests
  yaml_body = each.value
}
data "http" "rabbitmq_operator_crd" {
  url = "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
}
data "kubectl_file_documents" "rabbitmq_operator_crd" {
  content = data.http.rabbitmq_operator_crd.response_body
}
resource "kubectl_manifest" "rabbitmq_operator_crd" {
  for_each  = data.kubectl_file_documents.rabbitmq_operator_crd.manifests
  yaml_body = each.value
}
###############################################################################
# RabbitMQ                                                                    #
###############################################################################
# https://www.rabbitmq.com/kubernetes/operator/quickstart-operator.html       #
###############################################################################

# Cluster
# NOTE: Must be a kubectl_manifest instead of kubernetes_manifest in order to bypass CRD validation in planning stage
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1367
resource "kubectl_manifest" "rabbit_mq_cluster" {

  depends_on = [kubectl_manifest.rabbitmq_operator_crd]

  yaml_body = yamlencode({
    apiVersion = "rabbitmq.com/v1beta1"
    kind       = "RabbitmqCluster"
    metadata   = {
      name = "go-scale"
      namespace = "default"
    }
  })
}

###############################################################################
# Redis                                                                       #
###############################################################################
# https://github.com/bitnami/charts/tree/master/bitnami/redis                 #
###############################################################################

resource "helm_release" "redis" {
  name       = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "17.1.4"
}

###############################################################################
# OpenFaaS                                                                    #
###############################################################################
# https://artifacthub.io/packages/helm/openfaas/openfaas                      #
###############################################################################

# Namespaces
resource kubernetes_namespace "openfaas_fn" {
  metadata {
    name   = "openfaas-fn"
    labels = {
      role = "openfaas-fn"
    }
  }
}

resource kubernetes_namespace "openfaas_core" {
  metadata {
    name   = "openfaas"
    labels = {
      role = "openfaas-system"
    }
  }
}

# Release
resource "helm_release" "openfaas" {

  depends_on = [kubernetes_namespace.openfaas_core]

  name       = "faas"
  repository = "https://openfaas.github.io/faas-netes/"
  chart      = "openfaas"
  version    = "10.2.11"
  namespace  = kubernetes_namespace.openfaas_core.metadata[0].name

  set {
    name  = "functionNamespace"
    value = "openfaas-fn"
  }

  set {
    name  = "generateBasicAuth"
    value = "true"
  }
}

