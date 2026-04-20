FROM python:3.12

WORKDIR /app

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    build-essential \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir pandas sqlalchemy psycopg2-binary requests

COPY scripts/ingest_flights.py ingest_flights.py

ENTRYPOINT ["python", "ingest_flights.py"]