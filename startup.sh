#!/bin/bash

# Ingest files
echo "Ingesting files..."
ls -laR scripts
.venv/bin/python scripts/ingest_folder.py /ingest_docs

# Start the main application
echo "Starting Private GPT..."
exec .venv/bin/python -m private_gpt
