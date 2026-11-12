#!/usr/bin/env bash

set -u

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
health_check="$script_dir/health_check.sh"
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/health-check-test.XXXXXX") || {
    printf '%s\n' 'Test setup failed: could not create a temporary directory.' >&2
    exit 1
}
trap 'rm -rf -- "$temp_dir"' EXIT

if ! bash -n "$health_check"; then
    printf '%s\n' 'Health-check CLI syntax test failed.' >&2
    exit 1
fi

help_output=$(bash "$health_check" --help) || {
    printf '%s\n' 'The --help option failed.' >&2
    exit 1
}
if [[ "$help_output" != *'Usage: health_check.sh'* || "$help_output" != *'--meminfo FILE'* ]]; then
    printf '%s\n' 'The --help output is incomplete.' >&2
    exit 1
fi

self_test_output=$(bash "$health_check" --self-test) || {
    printf '%s\n' 'The --self-test option failed.' >&2
    exit 1
}
if [[ "$self_test_output" != *'Health-check self-test: PASS'* ]]; then
    printf '%s\n' 'The self-test did not report success.' >&2
    exit 1
fi

report_output=$(bash "$health_check") || {
    printf '%s\n' 'The default health report failed.' >&2
    exit 1
}
if [[ "$report_output" != *'Linux System Health Monitor'* ]]; then
    printf '%s\n' 'The default invocation did not print the health report.' >&2
    exit 1
fi

printf '%s\n' 'MemTotal: 2048 kB' 'MemAvailable: 1024 kB' >"$temp_dir/meminfo"
meminfo_output=$(bash "$health_check" --meminfo "$temp_dir/meminfo") || {
    printf '%s\n' 'The --meminfo option failed.' >&2
    exit 1
}
if [[ "$meminfo_output" != *'MemTotal: 2048 kB'* ]]; then
    printf '%s\n' 'The supplied meminfo file was not used.' >&2
    exit 1
fi

for invalid_args in '--unsupported' '--meminfo' '--help extra' '--self-test extra'; do
    read -r -a args <<<"$invalid_args"
    if bash "$health_check" "${args[@]}" >"$temp_dir/stdout" 2>"$temp_dir/stderr"; then
        printf 'Invalid invocation unexpectedly succeeded: %s\n' "$invalid_args" >&2
        exit 1
    else
        status=$?
    fi
    if [[ "$status" -ne 2 || ! -s "$temp_dir/stderr" ]]; then
        printf 'Invalid invocation returned the wrong error: %s\n' "$invalid_args" >&2
        exit 1
    fi
done

printf '%s\n' 'Health-check CLI tests: PASS'
