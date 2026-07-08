"""Great Expectations quality gate.

Runs AFTER dbt build and BEFORE deployment is allowed to proceed (wired into
CI). dbt tests cover structural rules (unique/not_null/relationships); this
gate adds value-level expectations on the marts. Exit code != 0 fails the
pipeline — quality is a deployment gate, not a report.
"""
import sys

import duckdb
import great_expectations as ge

DB = "dbt/local.duckdb"


def validate() -> bool:
    con = duckdb.connect(DB, read_only=True)
    ok = True

    fct = con.execute("select * from fct_daily_revenue").df()
    gx_fct = ge.from_pandas(fct)
    checks = [
        gx_fct.expect_column_values_to_be_between("revenue", min_value=0),
        gx_fct.expect_column_values_to_be_between("order_count", min_value=1),
        gx_fct.expect_column_values_to_not_be_null("category"),
        gx_fct.expect_column_values_to_be_between(
            "avg_order_value", min_value=0, max_value=10_000),
    ]

    dim = con.execute("select * from dim_customers").df()
    gx_dim = ge.from_pandas(dim)
    checks += [
        gx_dim.expect_column_values_to_be_unique("customer_id"),
        gx_dim.expect_column_values_to_be_between("lifetime_spend", min_value=0),
        gx_dim.expect_column_values_to_match_regex("province", r"^[A-Z]{2}$"),
    ]

    for result in checks:
        status = "PASS" if result.success else "FAIL"
        print(f"[{status}] {result.expectation_config.expectation_type} "
              f"{result.expectation_config.kwargs.get('column')}")
        ok = ok and result.success
    return ok


if __name__ == "__main__":
    passed = validate()
    print("\nQuality gate:", "PASSED" if passed else "FAILED")
    sys.exit(0 if passed else 1)
