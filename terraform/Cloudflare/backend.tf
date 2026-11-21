terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket = "terraform-homelab"
    key    = "Cloudflare/terraform.tfstate"

    endpoints = {
      s3 = "https://6c2ae2c66f79e23ac0cf8bb2b46bee21.r2.cloudflarestorage.com"
    }

    region = "auto"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    use_path_style              = true
  }
}