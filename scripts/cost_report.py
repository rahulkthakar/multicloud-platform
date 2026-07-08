"""Cross-cloud cost comparison.

Each provider exports billing in its own shape; this normalizes AWS CUR,
Azure Cost Management, and OCI Cost Analysis CSV exports into one schema
(date, cloud, service, tag_project, cost) and prints a comparison —
the basis of the platform's monthly showback.
"""
import sys
from pathlib import Path

import pandas as pd

NORMALIZERS = {
    "aws": lambda df: df.rename(columns={
        "lineItem/UsageStartDate": "date", "product/ProductName": "service",
        "resourceTags/user:project": "tag_project", "lineItem/UnblendedCost": "cost"}),
    "azure": lambda df: df.rename(columns={
        "UsageDateTime": "date", "MeterCategory": "service",
        "Tags_project": "tag_project", "PreTaxCost": "cost"}),
    "oci": lambda df: df.rename(columns={
        "lineItem/intervalUsageStart": "date", "product/service": "service",
        "tags/project": "tag_project", "cost/myCost": "cost"}),
}


def load(folder: Path) -> pd.DataFrame:
    frames = []
    for cloud, normalize in NORMALIZERS.items():
        f = folder / f"{cloud}_billing.csv"
        if f.exists():
            df = normalize(pd.read_csv(f))
            df["cloud"] = cloud
            df["date"] = pd.to_datetime(df["date"]).dt.date
            frames.append(df[["date", "cloud", "service", "tag_project", "cost"]])
    return pd.concat(frames, ignore_index=True)


def main(folder: str) -> None:
    df = load(Path(folder))
    print("== Spend by cloud ==")
    print(df.groupby("cloud")["cost"].sum().round(2).to_string())
    print("\n== Spend by project tag ==")
    print(df.groupby(["tag_project", "cloud"])["cost"].sum().round(2).to_string())
    print("\n== Top services ==")
    print(df.groupby(["cloud", "service"])["cost"].sum().round(2)
            .sort_values(ascending=False).head(8).to_string())


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "data/billing_samples")
