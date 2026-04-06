## Multi-Cloud Data Platform — DataOps with Observability & CI/CD

Production-grade data platform spanning **AWS, Azure, and OCI** with data
quality gates, lineage tracking, CI/CD automation, and cost governance —
replicating the operating model a Fortune-500 data team builds around its
lakehouse.

```
             ┌───────────────── one codebase, three clouds ─────────────────┐
             │  Terraform ──► AWS (S3 + Redshift Serverless + lifecycle)    │
             │            ──► Azure (ADLS Gen2)                             │
             │            ──► OCI (Object Storage + BUDGET + ALERTS)        │
             └──────────────────────────────────────────────────────────────┘
   seeds ─► dbt staging ─► dbt marts ─► dbt tests ─► Great Expectations gate
                │                                            │
                └── dbt-ol wrapper ──► OpenLineage events ───┘──► deploy
                          (job + dataset lineage)
   billing exports (3 clouds) ─► scripts/cost_report.py ─► showback
```

## What this demonstrates
| Capability | Where |
|---|---|
| CI/CD: every model change triggers tests + quality suite | `.github/workflows/ci.yml` |
| Structural data tests (unique / not-null / relationships / accepted values) | `dbt/models/**/ *.yml` |
| Value-level quality gate that BLOCKS deployment | `quality/run_quality_gate.py` (Great Expectations) |
| Data lineage per model | `dbt-ol` wrapper + `lineage/openlineage.yml` |
| Multi-cloud IaC from a single codebase with uniform cost tags | `terraform/` (module per cloud) |
| Cost governance as code: OCI budget + 80% alert, S3 lifecycle tiering | `terraform/modules/oci`, `modules/aws` |
| Cross-cloud cost comparison / showback | `scripts/cost_report.py` + sample billing exports |
| Design rationale on record | `docs/adr/` (Architecture Decision Records) |

## Run everything locally in 2 minutes (zero cloud cost)
The dbt project targets **DuckDB** in dev — the full build/test/quality loop
runs on a laptop; production targets (Redshift Serverless / Databricks) are a
profiles-only swap. Same models, different engine — that's the portability claim.

```bash
make setup      # pip install
make build      # dbt seed + build + dbt tests
make quality    # Great Expectations gate on the marts
make cost       # cross-cloud showback from sample billing exports
make lineage    # optional: emit OpenLineage events (run Marquez first)
```

## Deploy the infrastructure
```bash
cd terraform
terraform init
terraform plan          # AWS + Azure + OCI resources, uniformly tagged
terraform apply
```

## Design decisions
See `docs/adr/0001` (multi-cloud storage strategy) and `docs/adr/0002`
(quality gates in CI), and **WALKTHROUGH.md** for the interview-level tour.
