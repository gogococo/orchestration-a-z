variable "project" {
    description = "The GCP project name to deploy the cluster to."
}

variable "credentials" {
    description = "The GCP credentials file path to use, preferably a Terraform Service Account."
}

module "nomad" {
  source           = "picatz/nomad/google"
  version          = "2.0.0"
  project          = var.project
  credentials      = var.credentials
  bastion_enabled  = true
  server_instances = 3
  client_instances = 5
}

