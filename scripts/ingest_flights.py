import pandas as pd
from sqlalchemy import create_engine
import argparse
import re
import unicodedata


def normalize_column_name(col):
    col = str(col).strip().lower()
    col = unicodedata.normalize("NFKD", col).encode("ascii", "ignore").decode("ascii")
    col = re.sub(r"[^\w\s]", "", col)
    col = re.sub(r"\s+", "_", col)
    return col


def main(params):
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params.db
    table_name = params.table_name
    url = params.url

    print("=== INGESTING ===")
    print("READING:", url)

    df = pd.read_csv(url, 
                     sep=';', 
                     skiprows=1, 
                     on_bad_lines='skip', 
                     engine='python', 
                     encoding='latin-1')

    print("CSV READ SUCCESSFULLY")
    print("Shape:", df.shape)
    print("ORIGIN COLUMNS:", list(df.columns))

    df.columns = [normalize_column_name(c) for c in df.columns]

    print("Normalized Columns:", list(df.columns))

    engine = create_engine(
        f'postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}'
    )

    print("Connecting to database...")
    with engine.connect() as conn:
        print("Connection OK")

    print("Writing table...")
    df.to_sql(name=table_name, con=engine, if_exists='replace', index=False)

    print("TABLE CREATED SUCCESSFULLY")
    print("=== END INGESTION ===")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')

    parser.add_argument('--user', required=True)
    parser.add_argument('--password', required=True)
    parser.add_argument('--host', required=True)
    parser.add_argument('--port', required=True)
    parser.add_argument('--db', required=True)
    parser.add_argument('--table_name', required=True)
    parser.add_argument('--url', required=True)

    args = parser.parse_args()

    main(args)