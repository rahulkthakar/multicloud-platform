# Design Walkthrough (interview-level explanation of every component)

## The story in one paragraph
One dbt codebase transforms seeded raw data through staging views into
mart tables (a fact and a dimension), with structural tests declared in YAML.
CI runs the full build on DuckDB — so every PR gets a complete, free
test loop — then a Great Expectations gate validates VALUE-level rules on the
built marts and fails the pipeline on any violation: quality is a deployment
gate, not a report. The same models deploy to Redshift Serverless or
Databricks by swapping a dbt profile. Terraform provisions storage in all
three clouds from one codebase with uniform cost tags; OCI budgets/alerts and
S3 lifecycle tiering make cost governance part of the infrastructure. dbt runs
through the OpenLineage wrapper so every model emits job/dataset lineage, and
a cost script normalizes the three clouds' billing exports into one showback
view. ADRs record why.

## Anticipated questions

**Why dbt tests AND Great Expectations — isn't that redundant?**
Different layers: dbt YAML tests express structural contracts (keys, nulls,
referential integrity) next to the model; GE expresses value-level
expectations (ranges, formats) that gate the pipeline. ADR 0002 records the
split. In a Databricks-native build the GE role can be played by DLT
expectations — same principle, quality gates in the pipeline.

**Why DuckDB in dev?**
A full build+test loop with zero cloud cost and zero credentials — every
contributor and every CI run exercises the whole project. It also PROVES the
portability claim: identical models on a second engine.

**Where exactly is 'cost governance as code'?**
Three places: uniform tags in every module (attribution), OCI budget with an
80% alert rule (control), and S3 lifecycle transitions on raw data
(optimization). Plus the showback script that groups spend by the tag keys
Terraform enforces — the loop closes.

**What does OpenLineage give you over dbt docs?**
dbt docs show lineage inside the dbt project; OpenLineage is a cross-tool
STANDARD — the same events can come from Spark, Airflow, and dbt into one
graph, enabling impact analysis across the whole platform. In an Azure
enterprise, Purview plays this enterprise-graph role.

**How would this map onto Azure Databricks at an insurer?**
ADLS as the lake, dbt (or DLT) on Databricks SQL for silver→gold, Unity
Catalog for governance, DLT expectations/GE for gates, Asset Bundles + Azure
DevOps replacing GitHub Actions, and Purview replacing the local lineage
backend. The operating model — tests, gates, lineage, cost tags — transfers 1:1.

**What are the ADRs for?**
Decision memory. Distributed senior teams relitigate architecture without
written records; an ADR states context, decision, and consequences in one
page. As a lead, I require an ADR for any decision someone will question in
six months.
