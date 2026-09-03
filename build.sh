#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

rm -rf build
mkdir -p build

pip install -r requirements.txt -t build/ \
  --platform manylinux2014_aarch64 \
  --python-version 3.12 \
  --only-binary=:all: \
  --quiet

cp backend/survey.py build/

echo "Built build/ ($(du -sh build | cut -f1))"