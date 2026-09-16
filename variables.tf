variable "application_bucket_name" {
  description = "bucket used for permission testing"
  type        = string
}

variable "alert_email" {
  type = string

}


variable "alert_phone" {
  type      = string
  sensitive = true
}

variable "startupco_database_secret" {
  type      = string
  sensitive = true
}
