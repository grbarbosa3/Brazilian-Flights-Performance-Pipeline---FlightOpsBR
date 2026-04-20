import os
from google.cloud import storage, bigquery

PROJECT_ID = "zoomcamp-0001"
BUCKET_NAME = "zoomcamp-0001-brazil-flights-raw"
KEY_PATH = "terraform/keys/my-creds.json"

RAW_DATASET = "raw"

FILES = [
    {
        "local_path": "data/raw/VRA_202510.csv",
        "gcs_path": "flights/VRA_202510.csv",
        "table": "raw_brazil_flights",
        "delimiter": ";",
        "skip_rows": 2,
        "schema": [
            bigquery.SchemaField("icao_empresa_aerea", "STRING"),
            bigquery.SchemaField("numero_voo", "STRING"),
            bigquery.SchemaField("codigo_autorizacao_di", "STRING"),
            bigquery.SchemaField("codigo_tipo_linha", "STRING"),
            bigquery.SchemaField("icao_aerodromo_origem", "STRING"),
            bigquery.SchemaField("icao_aerodromo_destino", "STRING"),
            bigquery.SchemaField("partida_prevista", "STRING"),
            bigquery.SchemaField("partida_real", "STRING"),
            bigquery.SchemaField("chegada_prevista", "STRING"),
            bigquery.SchemaField("chegada_real", "STRING"),
            bigquery.SchemaField("situacao_voo", "STRING"),
            bigquery.SchemaField("codigo_justificativa", "STRING"),
        ]
    },
    {
        "local_path": "data/raw/AerodromosPublicos.csv",
        "gcs_path": "airports/public_airports.csv",
        "table": "raw_public_airports",
        "delimiter": ";",
        "skip_rows": 2,
        "schema": [
            bigquery.SchemaField("codigo_oaci", "STRING"),
            bigquery.SchemaField("ciad", "STRING"),
            bigquery.SchemaField("nome", "STRING"),
            bigquery.SchemaField("municipio", "STRING"),
            bigquery.SchemaField("uf", "STRING"),
            bigquery.SchemaField("municipio_servido", "STRING"),
            bigquery.SchemaField("uf_servido", "STRING"),
            bigquery.SchemaField("latgeopoint", "STRING"),
            bigquery.SchemaField("longeopoint", "STRING"),
            bigquery.SchemaField("latitude", "STRING"),
            bigquery.SchemaField("longitude", "STRING"),
            bigquery.SchemaField("altitude", "STRING"),
            bigquery.SchemaField("operacao_diurna", "STRING"),
            bigquery.SchemaField("operacao_noturna", "STRING"),
            bigquery.SchemaField("situacao", "STRING"),
            bigquery.SchemaField("validade_do_registro", "STRING"),
            bigquery.SchemaField("portaria_de_registro", "STRING"),
            bigquery.SchemaField("link_portaria", "STRING"),
        ]
    },
    {
        "local_path": "data/raw/AerodromosPrivados.csv",
        "gcs_path": "airports/private_airports.csv",
        "table": "raw_private_airports",
        "delimiter": ";",
        "skip_rows": 2,
        "schema": [
            bigquery.SchemaField("codigo_oaci", "STRING"),
            bigquery.SchemaField("ciad", "STRING"),
            bigquery.SchemaField("nome", "STRING"),
            bigquery.SchemaField("municipio", "STRING"),
            bigquery.SchemaField("uf", "STRING"),
            bigquery.SchemaField("longitude", "STRING"),
            bigquery.SchemaField("latitude", "STRING"),
            bigquery.SchemaField("altitude", "STRING"),
            bigquery.SchemaField("operacao_diurna", "STRING"),
            bigquery.SchemaField("operacao_noturna", "STRING"),
            bigquery.SchemaField("designacao_1", "STRING"),
            bigquery.SchemaField("comprimento_1", "STRING"),
            bigquery.SchemaField("largura_1", "STRING"),
            bigquery.SchemaField("resistencia_1", "STRING"),
            bigquery.SchemaField("superficie_1", "STRING"),
            bigquery.SchemaField("designacao_2", "STRING"),
            bigquery.SchemaField("comprimento_2", "STRING"),
            bigquery.SchemaField("largura_2", "STRING"),
            bigquery.SchemaField("resistencia_2", "STRING"),
            bigquery.SchemaField("superficie_2", "STRING"),
            bigquery.SchemaField("portaria_de_registro", "STRING"),
            bigquery.SchemaField("link_portaria", "STRING"),
            bigquery.SchemaField("latgeopoint", "STRING"),
            bigquery.SchemaField("longeopoint", "STRING"),
        ]
    },
    {
        "local_path": "data/raw/airlines.csv",
        "gcs_path": "airlines/airlines.csv",
        "table": "raw_airlines",
        "delimiter": ",",
        "skip_rows": 1,
        "schema": None  # autodetect - this one has proper English headers
    },
    {
        "local_path": "data/raw/airports.csv",
        "gcs_path": "airports/airports.csv",
        "table": "raw_airports",
        "delimiter": ",",
        "skip_rows": 1,
        "schema": None  # autodetect - this one has proper English headers
    }
]


def upload_to_gcs(storage_client, local_path, gcs_path):
    bucket = storage_client.bucket(BUCKET_NAME)
    blob = bucket.blob(gcs_path)

    print(f"Uploading {local_path} to gs://{BUCKET_NAME}/{gcs_path}")
    blob.upload_from_filename(local_path)


def load_to_bigquery(bq_client, gcs_path, table_name, field_delimiter=";", skip_rows=2, schema=None):
    table_id = f"{PROJECT_ID}.{RAW_DATASET}.{table_name}"
    uri = f"gs://{BUCKET_NAME}/{gcs_path}"

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=skip_rows,
        field_delimiter=field_delimiter,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
        encoding="ISO-8859-1",
    )
    
    if schema:
        job_config.schema = schema
    else:
        job_config.autodetect = True

    print(f"Loading {uri} to {table_id}")

    load_job = bq_client.load_table_from_uri(
        uri,
        table_id,
        job_config=job_config,
    )

    load_job.result()

    table = bq_client.get_table(table_id)
    print(f"Loaded {table.num_rows} rows into {table_id}")


def main():
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = KEY_PATH

    storage_client = storage.Client(project=PROJECT_ID)
    bq_client = bigquery.Client(project=PROJECT_ID)

    for file in FILES:
        upload_to_gcs(storage_client, file["local_path"], file["gcs_path"])
        load_to_bigquery(
            bq_client, 
            file["gcs_path"], 
            file["table"], 
            file["delimiter"],
            file["skip_rows"],
            file.get("schema")
        )

    print("Raw load finished.")


if __name__ == "__main__":
    main()