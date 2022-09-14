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