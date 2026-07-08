terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

variable "prefix" { type = string }
variable "tags" { type = map(string) }

# Lake bucket: versioned + encrypted by default.
resource "aws_s3_bucket" "lake" {
  bucket = "${var.prefix}-lake"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "lake" {
  bucket = aws_s3_bucket.lake.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lake" {
  bucket = aws_s3_bucket.lake.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "aws:kms" }
  }
}

# Lifecycle: age raw data to cheaper tiers — cost governance in code.
resource "aws_s3_bucket_lifecycle_configuration" "lake" {
  bucket = aws_s3_bucket.lake.id
  rule {
    id     = "age-raw-data"
    status = "Enabled"
    filter { prefix = "raw/" }
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

# Redshift Serverless: pay-per-use warehousing target for dbt prod runs.
resource "aws_redshiftserverless_namespace" "wh" {
  namespace_name = "${var.prefix}-wh"
  tags           = var.tags
}

resource "aws_redshiftserverless_workgroup" "wh" {
  namespace_name = aws_redshiftserverless_namespace.wh.namespace_name
  workgroup_name = "${var.prefix}-wg"
  base_capacity  = 8
  tags           = var.tags
}

output "lake_bucket" { value = aws_s3_bucket.lake.bucket }
