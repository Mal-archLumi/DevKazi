#!/usr/bin/env bash
set -e
rm -rf dist/  # Clean old build artifacts
npm install --legacy-peer-deps  # Install dependencies
npm run build  # Run 'tsc' to generate dist/main.js