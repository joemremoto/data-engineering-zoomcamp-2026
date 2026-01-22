terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.16.0"
    }
  }
}

provider "google" {
  project = "evocative-maker-485105-g6"
  region  = "asia-east1"
}

resource "google_storage_bucket" "demo-bucket" {
  name          = "evocative-maker-485105-g6-terra-bucket"
  location      = "ASIA"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}