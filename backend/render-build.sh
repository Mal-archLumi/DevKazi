#!/usr/bin/env bash
set -e
rm -rf dist/ node_modules/ package-lock.json  # Clean everything
npm cache clean --force  # Clear npm cache
npm install --legacy-peer-deps  # Fresh install
npm run build  # Run 'tsc'