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

  # Required for KinD clusters without a local registry.
  # https://docs.openfaas.com/reference/private-registries/#set-a-custom-imagepullpolicy
  set {
    name = "faasnetes.imagePullPolicy"
    value = "IfNotPresent"
  }

}
