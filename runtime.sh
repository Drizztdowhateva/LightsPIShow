#!/bin/bash

# Create and activate a Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run into.py with sensible defaults for headless mode
python into.py --headless

# Deactivate the virtual environment
deactivate
