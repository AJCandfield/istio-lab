locals {
  service = {
    name = "apps"

    namespace = {
      name = "main"
      labels = {
        "istio-injection" = "enabled"
      }
    }
  }
}
