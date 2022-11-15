# Single region, private only network configuration | network.tf

# create devops-vpc
resource "google_compute_network" "devops-vpc" {
  name                    = "${var.app_name}-${var.app_environment}-devops-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

# create private subnet
resource "google_compute_subnetwork" "private_subnet_1" {
  purpose       = "PRIVATE"
  name          = "${var.app_name}-${var.app_environment}-private-subnet-1"
  ip_cidr_range = var.private_subnet_cidr_1
  network       = google_compute_network.devops-vpc.name
  region        = var.gcp_region_1
  depends_on =[ google_compute_network.devops-vpc]
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
  network = google_compute_network.devops-vpc.name
  depends_on =[ google_compute_network.devops-vpc]
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
  network = google_compute_network.devops-vpc.name

  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = [
    "35.235.240.0/20"
  ]
  target_service_accounts = ["157139802489-compute@developer.gserviceaccount.com"]
  depends_on =[ google_compute_network.devops-vpc]
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
      email =   "157139802489-compute@developer.gserviceaccount.com"
      scopes = ["cloud-platform"]
    }

  metadata_startup_script = "sudo apt-get update; sudo apt install mysql-server -y; sudo systemctl start mysql.server;sudo mysql;"

  network_interface {
    network    = google_compute_network.devops-vpc.name
    subnetwork = google_compute_subnetwork.private_subnet_1.name
  }
    depends_on =[ google_compute_network.devops-vpc]
}


#Backend Terraform state file

 terraform {
    backend "gcs" {
        bucket = "vinaygcpdevops"
        credentials = "vinaygcpdevops.json"
    }
 }
