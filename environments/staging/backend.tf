terraform {
  backend "s3" {
    bucket       = "terraform-multienv-state-swayam"
    key          = "environments/staging/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}