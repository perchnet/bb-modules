# shellcheck shell=bash
setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    #load 'test_helper/bats-file/load'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    # shellcheck disable=SC2154
    DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")" >/dev/null 2>&1 && pwd)"
    DIR="$(realpath "${DIR}")"
    # make executables in src/ visible to PATH
    PATH="${DIR}/../src:${PATH}"
    # reset testdata
    rm -fr "${DIR}/testdata"
    "${DIR}/generate-testdata.sh" >/dev/null 2>&1 "${DIR}/testdata"
    #"${DIR}/generate-testdata.sh" 2>&1 "${DIR}/testdata"
}

### HELPER FUNCTIONS ###

# convert yaml to json for module_config
yaml_to_json() {
    local yaml="${1}"
    echo "${yaml}" | yq eval -o=j -I=0
}

# get_json_array helper that will be added by blue-build outside of tests
get_json_array() {
    local -n arr="${1}"
    local jq_query="${2}"
    local module_config="${3}"

    if [[ -z "${jq_query}" || -z "${module_config}" ]]; then
        echo "Usage: get_json_array VARIABLE_TO_STORE_RESULTS JQ_QUERY MODULE_CONFIG" >&2
        return 1
    fi

    readarray -t arr < <(echo "${module_config}" | jq -c -r "${jq_query}")
}

call_bin_wrapper() {
    local yaml="${1}"
    local json="$(yaml_to_json "${yaml}")"
    1>&3 echo "yaml: ${yaml}"
    1>&3 echo "json: ${json}"
    local bin_wrapper="${DIR}/../bin-wrapper.sh"
    source "${bin_wrapper}" "${json}"
}

@test "make sure yaml_to_json works" {
    local yaml
    yaml="---
    type: bin-wrapper
    bin: /home/bri/dev/desk/modules/bin-wrapper/testdata/executable
    flags:
      - --private-window
      - --new-tab https://example.com
    "
    run yaml_to_json "${yaml}" 1>&3
    assert_output '{"type":"bin-wrapper","bin":"/home/bri/dev/desk/modules/bin-wrapper/testdata/executable","flags":["--private-window","--new-tab https://example.com"]}'
}

@test "make sure get_json_array works" {
    local module_config
    module_config='{"type":"bin-wrapper","bin":"/home/bri/dev/desk/modules/bin-wrapper/testdata/executable","flags":["--private-window","--new-tab https://example.com"]}'
    local BIN
    local FLAGS
    get_json_array BIN 'try .["bin"]' "${module_config}"
    get_json_array FLAGS 'try .["flags"][]' "${module_config}"
    assert_equal "${BIN}" "/home/bri/dev/desk/modules/bin-wrapper/testdata/executable"
    assert_equal "${FLAGS[*]}" "--private-window --new-tab https://example.com"
}

@test "wrap a binary with flags" {
    local yaml
    yaml="---
    type: bin-wrapper
    bin: ${DIR}/testdata/executable
    flags:
      - --private-window
      - --new-tab https://example.com
    "
    run call_bin_wrapper "${yaml}"
    assert_success
    run "${DIR}/testdata/executable" foo bar
    assert_output "\$0 = $(realpath -e ${DIR}/testdata/executable.real)
--private-window
--new-tab\ https://example.com
foo
bar"
    
}