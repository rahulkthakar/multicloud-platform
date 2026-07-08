terraform {
  required_providers {
    oci = { source = "oracle/oci" }
  }
}

variable "prefix" { type = string }
variable "compartment_id" { type = string }
variable "budget_amount" { type = number }
variable "tags" { type = map(string) }

data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_id
}

resource "oci_objectstorage_bucket" "lake" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "${var.prefix}-lake"
  freeform_tags  = var.tags
}

# Budget + alert: cost governance built into the infrastructure itself.
resource "oci_budget_budget" "monthly" {
  compartment_id = var.compartment_id
  amount         = var.budget_amount
  reset_period   = "MONTHLY"
  display_name   = "${var.prefix}-monthly-budget"
  target_type    = "COMPARTMENT"
  targets        = [var.compartment_id]
  freeform_tags  = var.tags
}

resource "oci_budget_alert_rule" "at_80_percent" {
  budget_id      = oci_budget_budget.monthly.id
  type           = "ACTUAL"
  threshold      = 80
  threshold_type = "PERCENTAGE"
  display_name   = "80pct-actual"
  message        = "OCI spend has reached 80% of the monthly budget."
}

output "lake_bucket" { value = oci_objectstorage_bucket.lake.name }
