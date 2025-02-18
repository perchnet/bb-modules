#!/usr/bin/env bash
set -euxo pipefail
# test script

# First generate a directory with test data
TESTDATA_DIR="$(mktemp -d)"
trap 'rm -rf "${TESTDATA_DIR}"' EXIT
touch "${TESTDATA_DIR}/executable"
chmod 755 "${TESTDATA_DIR}/executable"
touch "${TESTDATA_DIR}/not_executable"
chmod 644 "${TESTDATA_DIR}/not_executable"
ln -s "${TESTDATA_DIR}/executable" "${TESTDATA_DIR}/link"
chmod 755 "${TESTDATA_DIR}/link"
