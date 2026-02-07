terraform {
  required_version = ">= 1.5"

  required_providers {
    outscale = {
      source  = "outscale/outscale"
      version = "~> 1.0"
    }
  }
}
