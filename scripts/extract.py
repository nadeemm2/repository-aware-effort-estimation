import pandas as pd
import mysql.connector
from pathlib import Path
import os

conn = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database="tawos_db"
)

output_dir = Path("data")
output_dir.mkdir(exist_ok=True)

tables = [
    "issue_text_baseline",
    "issue_repo_pre_estimation",
]

for table in tables:
    print(f"Exporting {table}...")

    query = f"SELECT * FROM {table}"
    df = pd.read_sql(query, conn)

    # Basic cleanup for CSV safety
    df = df.replace({r"\r\n": " ", r"\n": " ", r"\r": " "}, regex=True)

    csv_path = output_dir / f"{table}.csv"
    parquet_path = output_dir / f"{table}.parquet"

    df.to_csv(csv_path, index=False, encoding="utf-8")
    df.to_parquet(parquet_path, index=False)

    print(f"{table}: {len(df)} rows")
    print(f"Saved CSV: {csv_path}")
    print(f"Saved Parquet: {parquet_path}")

conn.close()
print("Done.")