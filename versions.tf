terraform {
  required_version = "~> 1.11"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 2.2"
    }
  }
}
