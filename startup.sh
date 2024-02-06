#!/bin/bash

# Setting up
echo "Setting up..."
.venv/bin/python scripts/setup

# Ingest files
echo "Ingesting files..."
.venv/bin/python scripts/ingest_folder.py /ingest_docs

# Start the main application
echo "Starting Private GPT..."
exec .venv/bin/python -m private_gpt
