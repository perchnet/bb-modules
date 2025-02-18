#!/usr/bin/env bash
# shellcheck disable=SC2154
set -euxo pipefail
# blue-build module for https://github.com/perchnet/bin-wrapper
# This module replaces links or bins in your distro with transparent wrappers that add flags or environment variables.
# It is useful for adding flags to a binary that is called by a link, or for adding flags to a binary that is called by a script.

BIN_WRAPPER_URL="https://raw.githubusercontent.com/perchnet/bin-wrapper/refs/heads/main/src/wrap-bin.sh"
#BIN_WRAPPER_URL="file:///${HOME}/dev/bin-wrapper/src/wrap-bin.sh"
### USAGE ###
# modules:
#   - type: bin-wrapper
#     bin: /usr/bin/firefox
#     flags:
#       - --private-window
#       - --new-tab https://example.com
#
# get_json_array() {
#   local -n arr="${1}"
#   local jq_query="${2}"
#   local module_config="${3}"
# 
#   if [[ -z "${jq_query}" || -z "${module_config}" ]]; then
#     echo "Usage: get_json_array VARIABLE_TO_STORE_RESULTS JQ_QUERY MODULE_CONFIG" >&2
#     return 1
#   fi
#
#   readarray -t arr < <(echo "${module_config}" | jq -c -r "${jq_query}")
# }
#
#
# yaml='---
# type: bin-wrapper
# bin: /home/bri/dev/desk/modules/bin-wrapper/testdata/executable
# flags:
#   - --private-window
#   - --new-tab https://example.com
# '
# module_config="$(echo "$yaml" | yq eval -o=j -I=0)"
JSON_ARRAY="${1:?Usage: bin-wrapper.sh <module_config>}"
get_json_array BIN 'try .["bin"]' "${module_config:-"${JSON_ARRAY}"}"
get_json_array FLAGS 'try .["flags"][]' "${module_config:-"${JSON_ARRAY}"}"

1>&3 echo "BIN: ${BIN}"
1>&3 echo "FLAGS: ${FLAGS[*]}"

#FLAGS=("--private-window" "--new-tab https://example.com")
TMP_BIN_WRAPPER="$(mktemp)"
curl -sSL "${BIN_WRAPPER_URL}" -o "${TMP_BIN_WRAPPER}"
chmod +x "${TMP_BIN_WRAPPER}"
<"${TMP_BIN_WRAPPER}" tee /tmp/ffflog
"${TMP_BIN_WRAPPER}" "${BIN}" "${FLAGS[@]}"
< "${BIN}" tee -a /tmp/ffflog