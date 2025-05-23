terraform {
  required_version = "> 0.8.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.0.0-pre2"
    }
  }
}

resource "null_resource" "create_kind_cluster" {

  provisioner "local-exec" {  
    command = "kubectl get nodes; if [ $? -ne 0 ]; then kind get clusters && kind delete clusters istio && kind create cluster --name istio --config cluster/config --image='kindest/node:v1.31.6' && kind export kubeconfig --name istio; else kind export kubeconfig --name istio; fi"
  }
  provisioner "local-exec" {
    when = destroy
    command = "kind get clusters | xargs -t -n1 kind delete cluster --name"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "helm_release" "metallb" {
  name       = "metallb"
  namespace  = "metallb-system"
  chart = "./metallb"
  create_namespace = "true"
}
resource "kubernetes_manifest" "metallb_pool" {
  manifest = yamldecode(file("${path.module}/metallb/pool.yaml"))
  depends_on = [helm_release.metallb]
}
resource "kubernetes_manifest" "metallb_advertisement" {
  manifest = yamldecode(file("${path.module}/metallb/advertisement.yaml"))
  depends_on = [helm_release.metallb]
}


provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "istiod" {
  name       = "istio"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  create_namespace = "true"
  namespace  = "istio-system"
  values = [
    "${file("istio/istiod/values.yaml")}"
  ]
}
resource "helm_release" "istio-base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  create_namespace = "true"
  namespace  = "istio-system"
}
resource "helm_release" "istio-ingressgateway" {
  name       = "ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  create_namespace = "true"
  namespace  = "istio-system"
  values = [
    "${file("istio/gateways/ingress/values.yaml")}"
  ]
  version = "1.24.3"
}
