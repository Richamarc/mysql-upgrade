# Setup Terraform to work with Google
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.50.0"
    }
  }
}
provider "google" {
  credentials = file("./gcp-private.json")

  project = "bathtub-pilot"
  region  = "northamerica-northeast2"
  zone    = "northamerica-northeast2-a"
}


# Create VPC and subnets
resource "google_compute_network" "vpc_network" {
  name                    = "bathtub-network"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "default" {
  name          = "bathtub-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "northamerica-northeast2"
  network       = google_compute_network.vpc_network.id
}


# Create a single Compute Engine instance
resource "google_compute_instance" "default" {
  name         = "flask-vm"
  machine_type = "f1-micro"
  zone         = "northamerica-northeast2-a"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
  metadata = {
    enable-oslogin = "TRUE"
  }
}
resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}
resource "google_compute_firewall" "flask" {
  name    = "flask-app-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
  source_ranges = ["0.0.0.0/0"]
}
// A variable for extracting the external IP address of the VM
output "Web-server-URL" {
  value = join("", ["http://", google_compute_instance.default.network_interface.0.access_config.0.nat_ip, ":5000"])
}