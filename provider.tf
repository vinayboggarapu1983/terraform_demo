terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  required_version = ">= 0.18"
}

provider "google" {
  project     = var.app_project
  credentials = file(var.authentication_file)
  region      = var.gcp_region_1
  zone        = var.gcp_zone_1
}