###############################################################################
# RabbitMQ                                                                    #
###############################################################################
# https://www.rabbitmq.com/kubernetes/operator/quickstart-operator.html       #
###############################################################################

# RabbitMQ Operator Custom Resource Definitions
data "http" "rabbitmq_operator_crd" {
  url = "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
}
data "kubectl_file_documents" "rabbitmq_operator_crd" {
  content = data.http.rabbitmq_operator_crd.response_body
}
resource "kubectl_manifest" "rabbitmq_operator_crd" {
  //noinspection HILUnresolvedReference
  for_each  = data.kubectl_file_documents.rabbitmq_operator_crd.manifests
  yaml_body = each.value
}

# Cluster
# NOTE: Must be a kubectl_manifest instead of kubernetes_manifest in order to bypass CRD validation in planning stage
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1367
resource "kubectl_manifest" "rabbit_mq_cluster" {

  depends_on = [kubectl_manifest.rabbitmq_operator_crd]

  yaml_body = yamlencode({
    apiVersion = "rabbitmq.com/v1beta1"
    kind       = "RabbitmqCluster"
    metadata   = {
      name = "rabbitmq"
      namespace = "default"
    }
  })
}