###############################################################################
# CRD's                                                                       #
###############################################################################

# Nginx Ingress Custom Resource Definitions
data "http" "ingress_crd" {
  url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
}
data "kubectl_file_documents" "ingress_crd" {
  content = data.http.ingress_crd.response_body
}
resource "kubectl_manifest" "ingress_crd" {
  //noinspection HILUnresolvedReference
  for_each  = data.kubectl_file_documents.ingress_crd.manifests
  yaml_body = each.value
}
