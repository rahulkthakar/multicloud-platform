variable "prefix" {
  type    = string
  default = "rkt-mcp"
}
variable "env" {
  type    = string
  default = "dev"
}
variable "aws_region" {
  type    = string
  default = "ca-central-1"
}
variable "azure_location" {
  type    = string
  default = "canadacentral"
}
variable "oci_region" {
  type    = string
  default = "ca-toronto-1"
}
variable "oci_compartment_id" {
  type        = string
  description = "OCID of the target OCI compartment"
  default     = "ocid1.compartment.oc1..replace-me"
}
variable "oci_budget_amount" {
  type        = number
  description = "Monthly OCI budget (CAD) that triggers alerts"
  default     = 200
}
