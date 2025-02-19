#!/usr/bin/env bash
# shellcheck disable=SC2154
set -euxo pipefail
# blue-build module for https://github.com/perchnet/bin-wrapper
# This module replaces links or bins in your distro with transparent wrappers that add flags or environment variables.
# It is useful for adding flags to a binary that is called by a link, or for adding flags to a binary that is called by a script.

BIN_WRAPPER_URL="https://raw.githubusercontent.com/perchnet/bin-wrapper/refs/heads/main/src/wrap-bin.sh"
### USAGE ###
# modules:
#   - type: bin-wrapper
#     bin: /usr/bin/firefox
#     flags:
#       - --private-window
#       - --new-tab https://example.com

JSON_ARRAY="${1:?Usage: bin-wrapper.sh <module_config>}"
get_json_array BIN 'try .["bin"]' "${module_config:-"${JSON_ARRAY}"}"
get_json_array FLAGS 'try .["flags"][]' "${module_config:-"${JSON_ARRAY}"}"

echo "BIN: ${BIN}"
echo "FLAGS: ${FLAGS[*]}"

# run the bin-wrapper script with the bin and flags
curl -sSL "${BIN_WRAPPER_URL}" | bash -s -- "${BIN}" "${FLAGS[@]}"