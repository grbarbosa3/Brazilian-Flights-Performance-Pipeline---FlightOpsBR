import pandas as pd
from sqlalchemy import create_engine
from pathlib import Path

CSV_PATH = Path(__file__).parent.parent / "data" / "raw" / "airports.csv"

engine = create_engine(
    "postgresql+psycopg2://root:root@localhost:5555/brazil_flights"
)

df = pd.read_csv(CSV_PATH, dtype=str)   

df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_")
    .str.replace("-", "_")
)

df.to_sql(
    "raw_international_airports",
    engine,
    schema="public",
    if_exists="replace",
    index=False,
    chunksize=5000,
    method="multi"
)

print(f"Tabela enviada com sucesso: {len(df)} linhas")
print(df.columns.tolist())