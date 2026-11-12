#!/usr/bin/env bash

set -u

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

run_report() {
    local os_name="Unknown"
    local meminfo_file="${1:-/proc/meminfo}"
    local force_meminfo="${2:-false}"

    printf '%s\n' 'Linux System Health Monitor' '---------------------------'
    if command_exists uname; then
        os_name=$(uname -s 2>/dev/null || printf '%s' 'Unknown')
    fi
    printf 'Operating system: %s\n' "$os_name"

    printf 'Uptime and load: '
    if command_exists uptime; then
        uptime 2>/dev/null || printf '%s\n' 'Unavailable'
    else
        printf '%s\n' 'Unavailable'
    fi

    printf '%s\n' 'Memory:'
    if [[ "$force_meminfo" == true ]]; then
        if [[ -r "$meminfo_file" ]]; then
            awk '/^(MemTotal|MemAvailable):/ { print }' "$meminfo_file"
        else
            printf '%s\n' 'Unavailable on this system'
        fi
    elif command_exists free; then
        free -h 2>/dev/null || printf '%s\n' 'Unavailable'
    elif [[ -r "$meminfo_file" ]]; then
        awk '/^(MemTotal|MemAvailable):/ { print }' "$meminfo_file"
    else
        printf '%s\n' 'Unavailable on this system'
    fi

    printf '%s\n' 'Disk usage for /:'
    if command_exists df; then
        df -h / 2>/dev/null || printf '%s\n' 'Unavailable'
    else
        printf '%s\n' 'Unavailable'
    fi

    printf 'Service manager: '
    if command_exists systemctl && systemctl --version >/dev/null 2>&1; then
        printf '%s\n' 'systemd available'
    else
        printf '%s\n' 'systemd not detected'
    fi
}

run_self_test() {
    command_exists() {
        case "$1" in
            uname|uptime|df) return 0 ;;
            *) return 1 ;;
        esac
    }
    uname() { printf '%s\n' 'Linux'; }
    uptime() { printf '%s\n' 'up 1 day, load average: 0.10, 0.20, 0.30'; }
    df() { printf '%s\n' 'Filesystem Size Used Avail Use% Mounted on /dev/test 10G 2G 8G 20% /'; }

    local meminfo_fixture
    meminfo_fixture=$(mktemp "${TMPDIR:-/tmp}/health-check-meminfo.XXXXXX") || {
        printf '%s\n' 'Self-test failed: could not create a temporary meminfo fixture.' >&2
        return 1
    }
    if ! printf '%s\n' 'MemTotal: 1024 kB' 'MemAvailable: 512 kB' >"$meminfo_fixture"; then
        rm -f -- "$meminfo_fixture"
        printf '%s\n' 'Self-test failed: could not write the meminfo fixture.' >&2
        return 1
    fi

    local output
    output=$(run_report "$meminfo_fixture" true)
    for expected in 'Operating system: Linux' 'Uptime and load:' 'Memory:' 'MemTotal: 1024 kB' 'MemAvailable: 512 kB' 'Disk usage for /:' 'Service manager: systemd not detected'; do
        if [[ "$output" != *"$expected"* ]]; then
            rm -f -- "$meminfo_fixture"
            printf 'Self-test failed: expected output to contain "%s"\n' "$expected" >&2
            return 1
        fi
    done

    output=$(run_report /path/not-present-for-self-test true)
    if [[ "$output" != *'Unavailable on this system'* ]]; then
        rm -f -- "$meminfo_fixture"
        printf '%s\n' 'Self-test failed: missing meminfo did not report as unavailable.' >&2
        return 1
    fi
    rm -f -- "$meminfo_fixture"
    printf '%s\n' 'Health-check self-test: PASS'
}

usage() {
    cat <<'USAGE'
Usage: health_check.sh [--help | --self-test | --meminfo FILE]

With no options, print a system health report.
  --help       Show this help and exit.
  --self-test  Run deterministic report checks without changing the system.
  --meminfo    Read memory details from FILE instead of the free command.
USAGE
}

main() {
    local meminfo_file="/proc/meminfo"
    local force_meminfo=false
    while (($#)); do
        case "$1" in
            --help|-h)
                if (($# != 1)); then
                    printf '%s\n' 'Unexpected arguments after --help.' >&2
                    usage >&2
                    return 2
                fi
                usage
                return 0
                ;;
            --self-test)
                if (($# != 1)); then
                    printf '%s\n' 'Unexpected arguments after --self-test.' >&2
                    usage >&2
                    return 2
                fi
                run_self_test
                return $?
                ;;
            --meminfo)
                if (($# < 2)) || [[ -z "$2" ]]; then
                    printf '%s\n' 'Missing file path after --meminfo.' >&2
                    usage >&2
                    return 2
                fi
                meminfo_file=$2
                force_meminfo=true
                shift 2
                ;;
            *)
                printf 'Unknown argument: %s\n' "$1" >&2
                usage >&2
                return 2
                ;;
        esac
    done
    run_report "$meminfo_file" "$force_meminfo"
}

main "$@"
