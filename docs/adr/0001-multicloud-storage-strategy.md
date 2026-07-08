# ADR 0001 — Multi-cloud storage and warehousing strategy

## Status
Accepted

## Context
The platform must demonstrate portability across AWS, Azure, and OCI while
keeping one transformation codebase and one governance/cost model. Vendor
lock-in risk and per-cloud pricing differences motivated an explicit strategy
rather than ad-hoc per-cloud builds.

## Decision
1. **Open formats at rest** (Parquet/Delta-compatible) in each cloud's object
   store (S3 / ADLS Gen2 / OCI Object Storage) — data is portable by copy,
   not by re-engineering.
2. **One transformation codebase (dbt)** with per-target profiles: DuckDB for
   local dev (zero cost, full test loop), Redshift Serverless or Databricks
   for production — models unchanged across targets.
3. **One Terraform codebase** with a module per cloud and UNIFORM tag keys
   (project/owner/env) so cost attribution is identical everywhere.
4. **Cost governance as infrastructure**: OCI budget + alert resources and S3
   lifecycle tiering are declared in Terraform, not configured by hand.

## Consequences
+ Portability is demonstrated by running the identical dbt project on two engines.
+ Cost comparison across clouds is a query, not a spreadsheet exercise.
- Multi-cloud means three provider credentials/pipelines to manage in CI.
- Lowest-common-denominator features only in the shared layer; cloud-native
  extras are isolated inside their module.
