#!/bin/bash

# Ingest files
echo "Ingesting files..."
python /home/root/app/scripts/ingest_files.py /ingest_docs

# Start the main application
echo "Starting Private GPT..."
exec .venv/bin/python -m private_gpt
