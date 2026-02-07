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
      image_id  = "ami-12345678"
      vm_type   = "tinav5.c1r1p1"
      subnet_id = "subnet-12345678"
    }
  }
}
