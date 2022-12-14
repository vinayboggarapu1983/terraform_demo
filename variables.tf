# network varibles | network-single-region.tf

# define GCP region
variable "gcp_region_1" {
  type        = string
  description = "GCP region"
}

# define GCP zone
variable "gcp_zone_1" {
  type        = string
  description = "GCP zone"
}

# define private subnet
variable "private_subnet_cidr_1" {
  type        = string
  description = "private subnet CIDR 1"
}

# GCP authentication file
variable "authentication_file" {
  type        = string
  description = "GCP authentication file"
}

# define GCP project name
variable "app_project" {
  type        = string
  description = "GCP project name"
}

# define application name
variable "app_name" {
  type        = string
  description = "Application name"
}

# define application domain
variable "app_domain" {
  type        = string
  description = "Application domain"
}

# define application environment
variable "app_environment" {
  type        = string
  description = "Application environment"
}

variable "app_node_count" {
  type        = string
  description = "Number of servers to build"
}

variable "app_service_account" {
  type        = string
  description = "Application service account"
}