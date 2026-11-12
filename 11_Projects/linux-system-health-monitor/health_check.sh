#!/usr/bin/env bash

set -u

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

run_report() {
    local os_name="Unknown"
    local meminfo_file="${1:-/proc/meminfo}"

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
    if command_exists free; then
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

    local output
    output=$(run_report /path/not-present-for-self-test)
    for expected in 'Operating system: Linux' 'Uptime and load:' 'Memory:' 'Unavailable on this system' 'Disk usage for /:' 'Service manager: systemd not detected'; do
        if [[ "$output" != *"$expected"* ]]; then
            printf 'Self-test failed: expected output to contain "%s"\n' "$expected" >&2
            return 1
        fi
    done
    printf '%s\n' 'Health-check self-test: PASS'
}

if [[ "${1:-}" == '--self-test' ]]; then
    run_self_test
else
    run_report
fi
