#!/usr/bin/env bash
set -euxo pipefail

# First generate a directory with test data
TESTDATA_DIR="${1:?"Usage: generate-testdata.sh <directory>"}"
mkdir -p "${TESTDATA_DIR}"
# shellcheck disable=SC2016 # because we don't need to expand $TEST_SCRIPT
TEST_SCRIPT='#!/usr/bin/env bash
echo "\$0 = $0"
for a in "$@"; do
    printf "%q\n" "${a}"
done
'
tee "${TESTDATA_DIR}/executable" <<<"${TEST_SCRIPT}"
chmod 755 "${TESTDATA_DIR}/executable"
touch "${TESTDATA_DIR}/not_executable"
chmod 644 "${TESTDATA_DIR}/not_executable"
ln -s "${TESTDATA_DIR}/executable" "${TESTDATA_DIR}/link"
chmod 755 "${TESTDATA_DIR}/link"