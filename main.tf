resource "random_integer" "example" {
  min = 1
  max = 100
  keepers = {
    example = var.example
  }
}

locals {
  example = format("%v %v", var.example, join("", random_integer.example[*].result))
}
