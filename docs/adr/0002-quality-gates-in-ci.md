# ADR 0002 — Data quality as a CI deployment gate

## Status
Accepted

## Context
Quality checks that run "after the fact" produce reports nobody reads; bad
data reaches consumers first. The platform needed quality enforcement at the
same point code quality is enforced: before merge/deploy.

## Decision
Two complementary layers, both blocking:
1. **dbt tests** for structural contracts — uniqueness, not-null,
   referential integrity, accepted values — run as part of `dbt build`.
2. **Great Expectations** for value-level expectations on marts —
   ranges, formats, distributions — run by `quality/run_quality_gate.py`,
   exiting non-zero on any failure.
CI order: build models → dbt tests → GE gate → (only then) deploy.

## Consequences
+ A failing expectation blocks the pipeline exactly like a failing unit test.
+ Rule ownership is explicit: structure in dbt YAML, values in the GE script.
- Gate rules need maintenance as data evolves; thresholds are reviewed with
  data owners, not guessed by engineers.
