# Single codebase provisioning the platform's storage + warehousing across
# three clouds, with uniform cost-attribution tags (the same tag keys are
# what scripts/cost_report.py groups by).
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws     = { source = "hashicorp/aws", version = "~> 5.50" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.100" }
    oci     = { source = "oracle/oci", version = "~> 5.40" }
  }
}

provider "aws" { region = var.aws_region }
provider "azurerm" { features {} }
provider "oci" { region = var.oci_region }

locals {
  tags = {
    project = "multicloud-platform"
    owner   = "rahul.thakar"
    env     = var.env
  }
}

module "aws" {
  source = "./modules/aws"
  prefix = var.prefix
  tags   = local.tags
}

module "azure" {
  source   = "./modules/azure"
  prefix   = var.prefix
  location = var.azure_location
  tags     = local.tags
}

module "oci" {
  source          = "./modules/oci"
  prefix          = var.prefix
  compartment_id  = var.oci_compartment_id
  budget_amount   = var.oci_budget_amount
  tags            = local.tags
}
