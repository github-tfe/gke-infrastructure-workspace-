provider "helm" {
  kubernetes {
    host                   = module.gke_cluster.gke_endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = module.gke_cluster.cluster_ca_certificate
  }
}
provider "kubernetes" {
  host                   = module.gke_cluster.gke_endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = module.gke_cluster.cluster_ca_certificate
}

provider "kubectl" {
  host                   = module.gke_cluster.gke_endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = module.gke_cluster.cluster_ca_certificate
  load_config_file       = false
}

resource "google_compute_network" "gke_test" {
  name                    = "test-gke-module1"
  auto_create_subnetworks = false
  project                 = "liatrio-mission-368815"
}

resource "google_compute_subnetwork" "subnet_k8s" {
  name          = "k8s-test-module1"
  ip_cidr_range = "10.10.0.0/24"
  region        = "us-east1"
  network       = google_compute_network.gke_test.name
  project       = "liatrio-mission-368815"
}

module "gke_cluster" {
  source                   = "../../gke-modules"
  region                   = "us-east1"
  cluster_name             = "liatrio-cluster"
  project_id               = "liatrio-mission-368815"
  disable_istio            = true
  private_endpoint         = false
  network                  = google_compute_network.gke_test.self_link
  subnetwork               = google_compute_subnetwork.subnet_k8s.self_link
  master_ipv4_cidr_block   = "172.16.5.0/28"
  kubernetes_version       = "1.22.12-gke.2300"
  network_policies_enabled = true
  config_connector_enabled = false
  csi_addon_enabled        = true

  master_authorized_networks_config = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "Every IPv4 address"
    },
  ]

  node_pools = {
    nodepool1 = {
      node_pools_names            = "nodepool2"
      machine_type                = "n1-standard-1"
      project_id                  = "liatrio-mission-368815"
      version                     = "1.22.12-gke.2300"
      nodepool_initial_node_count = 1
      disk_size_gb                = "100"
      disk_type                   = "pd-standard"
      image_type                  = "cos_containerd"
      metadata = {
        disable-legacy-endpoints = true
      }
      oauth_scopes = [
        "https://www.googleapis.com/auth/compute",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }
}

resource "google_service_account" "verifier" {
  project    = "liatrio-mission-368815"
  account_id = "gke-mod-test-verifier"
}

resource "google_service_account_key" "verifier" {
  service_account_id = google_service_account.verifier.email
}

data "google_client_config" "default" {}


data "kubectl_file_documents" "deployment" {
  content = file("./kubernetes_files/deployment.yaml")
}

data "kubectl_file_documents" "service" {
  content = file("./kubernetes_files/service.yaml")
}

data "kubectl_file_documents" "ingress" {
  content = file("./kubernetes_files/ingress.yaml")
}


resource "kubectl_manifest" "application1" {
  count      = length(data.kubectl_file_documents.deployment.documents)
  yaml_body  = element(data.kubectl_file_documents.deployment.documents, count.index)
  depends_on = [module.gke_cluster]
}


resource "kubectl_manifest" "service" {
  count     = length(data.kubectl_file_documents.service.documents)
  yaml_body = element(data.kubectl_file_documents.service.documents, count.index)
  depends_on = [module.gke_cluster]
}

resource "kubectl_manifest" "ingress" {
  count     = length(data.kubectl_file_documents.ingress.documents)
  yaml_body = element(data.kubectl_file_documents.ingress.documents, count.index)
  depends_on = [module.gke_cluster]
}


