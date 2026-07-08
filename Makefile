.PHONY: setup build test quality lineage cost tf-validate

setup:
	pip install -r requirements.txt

build:            ## dbt: seed raw data, build models, run dbt tests (local duckdb)
	cd dbt && dbt seed --profiles-dir . && dbt build --profiles-dir .

quality:          ## Great Expectations gate on the built marts
	python quality/run_quality_gate.py

lineage:          ## run dbt through the OpenLineage wrapper (emits lineage events)
	cd dbt && OPENLINEAGE_CONFIG=../lineage/openlineage.yml dbt-ol build --profiles-dir .

cost:             ## cross-cloud cost comparison from billing exports
	python scripts/cost_report.py data/billing_samples

tf-validate:
	cd terraform && terraform init -backend=false && terraform validate
