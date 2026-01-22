variable "credentials" {
  description = "Path to GCP Credentials JSON file"
  default     = "./keys/my-creds.json"
}

variable "project" {
  description = "Project"
  default     = "evocative-maker-485105-g6"
}

variable "location" {
  description = "Project Location"
  default     = "ASIA-EAST1"
}

variable "region" {
  description = "Project Region"
  default     = "asia-east1"
}

variable "bq" {
  description = "My BigQuery Dataset Name"
  default     = "demo_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "evocative-maker-485105-g6-terra-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}