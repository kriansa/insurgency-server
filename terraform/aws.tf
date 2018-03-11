# These variables are likely to be set on your environments/<env>.tfvars
# ======================================================================
variable aws_region {
  type = "string"
}

variable aws_profile {
  type = "string"
}

# Declare an AWS provider
# =======================
provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}
