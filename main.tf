# Single region, private only network configuration | network.tf

# create Assesment8_VPC
resource "google_compute_network" "Assesment8_VPC" {
  name                    = "${var.app_name}-${var.app_environment}-Assesment8_VPC"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

# create private subnet
resource "google_compute_subnetwork" "A8_private_subnet_1" {
  purpose       = "PRIVATE"
  name          = "${var.app_name}-${var.app_environment}-private-subnet-1"
  ip_cidr_range = var.private_subnet_cidr_1
  network       = google_compute_network.Assesment8_VPC.name
  region        = var.gcp_region_1
  depends_on =[ google_compute_network.Assesment8_VPC]
}


# create a public ip for nat service
resource "google_compute_address" "nat_ip" {
  name    = "${var.app_name}-${var.app_environment}-nap-ip"
  project = var.app_project
  region  = var.gcp_region_1
}

# create a nat to allow private instances connect to internet
resource "google_compute_router" "nat-router" {
  name    = "${var.app_name}-${var.app_environment}-nat-router"
  network = google_compute_network.Assesment8_VPC.name
  depends_on =[ google_compute_network.Assesment8_VPC]
}

resource "google_compute_router_nat" "nat-gateway" {
  name                               = "${var.app_name}-nat-gateway"
  router                             = google_compute_router.nat-router.name
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  depends_on                         = [google_compute_address.nat_ip]
}


## Allow incoming access to our instance via
## port 22, from the IAP servers
resource "google_compute_firewall" "inbound-ip-ssh" {
  name    = "${var.app_name}-${var.app_environment}-allow-inc-ssh-from-iap"
  network = google_compute_network.Assesment8_VPC.name

  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = [
    "35.235.240.0/20"
  ]
  target_service_accounts = ["projectnumber-compute@devolper.gservicesaccounts.com"]
  depends_on =[ google_compute_network.Assesment8_VPC]
}

# Create Google Cloud VMs

# Create web server #1
resource "google_compute_instance" "web_private_1" {
  name         = "${var.app_name}-${var.app_environment}-vm1"
  machine_type = "e2-small"
  zone         = var.gcp_zone_1
  hostname     = "${var.app_name}-${var.app_environment}-vm1.${var.app_domain}"
  tags         = ["ssh", "http"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
 service_account {
      email =  "projectnumber-compute@devolper.gservicesaccounts.com"
      scopes = ["cloud-platform"]
    }

  metadata_startup_script = "sudo apt-get update; sudo apt install mysql-server -y; sudo systemctl start mysql.server;sudo mysql;"

  network_interface {
    network    = google_compute_network.Assesment8_VPC.name
    subnetwork = google_compute_subnetwork.A8_private_subnet_1.name
  }
    depends_on =[ google_compute_network.Assesment8_VPC]
}

resource "google_iap_tunnel_instance_iam_member" "iap_instance" {
  instance = google_compute_instance.web_private_1.name
  zone     = var.gcp_zone_1
  role     = "roles/iap.tunnelResourceAccessor"
  member   = "user:candidate8@ostendere.net"
  depends_on = [google_compute_instance.web_private_1]
}


#Creating Private MySql Instance

resource "random_id" "suffix" {
  byte_length = 5
}

locals {
  /*
    Random instance name needed because:
    "You cannot reuse an instance name for up to a week after you have deleted an instance."
    See https://cloud.google.com/sql/docs/mysql/delete-instance for details.
  */
  network_name = "${var.network_name}-safer-${random_id.suffix.hex}"
}

module "network-safer-mysql-simple" {
  source  = "terraform-google-modules/network/google"
  version = "~> 4.0"

  project_id   = "${var.app_name}"
  network_name = "${var.app_name}-${var.app_environment}-Assesment8_VPC"

  subnets = []
}

module "private-service-access" {
  source      = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
  project_id  = "${var.app_name}"
  Assesment8_VPC_network = module.network-safer-mysql-simple.network_name
}

module "safer-mysql-db" {
  source               = "GoogleCloudPlatform/sql-db/google//modules/safer_mysql"
  name                 = var.db_name
  random_instance_name = true
  project_id           = var.project_id

  deletion_protection = false

  database_version = "MYSQL_5_6"
  region           =  var.gcp_region_1
  zone             = var.gcp_zone_1
  tier             = "db-n1-standard-1"

  // By default, all users will be permitted to connect only via the
  // Cloud SQL proxy.
  additional_users = [
    {
      name     = "app"
      password = "a2v5gd"
      host     = "localhost"
      type     = "BUILT_IN"
    },
  ]

  assign_public_ip   = "true"
  Assesment8_VPC_network        = module.network-safer-mysql-simple.network_self_link
  allocated_ip_range = module.private-service-access.google_compute_global_address_name

  // Optional: used to enforce ordering in the creation of resources.
  module_depends_on = [module.private-service-access.peering_completed]
}

#Backend Terraform state file

 terraform {
    backend "gcs" {
        bucket = "assessment-8"
        credentials = "key.json"
    }
 }

