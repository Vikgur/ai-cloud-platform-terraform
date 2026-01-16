#!/usr/bin/env bash
set -e

dirs=(
)

for d in "${dirs[@]}"; do
  mkdir -p "$d"
done

files=(
)

for f in "${files[@]}"; do
  touch "$f"
done

echo "AI skeleton created for Terraform project."
