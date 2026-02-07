provider "outscale" {
  region = "eu-west-2"
}

module "compute" {
  source = "../.."

  project_name = "myproject"
  environment  = "dev"

  vms = {
    web = {
      count     = 1
      image_id  = "ami-a4221a17" # Ubuntu 24.04 (2026-01-12)
      vm_type   = "tinav5.c1r1p1"
      subnet_id = "subnet-12345678"
    }
  }
}
