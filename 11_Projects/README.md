## Linux System Health Monitor

The health-check script prints operating-system, uptime/load, memory, disk, and service-manager information without changing system state.

```bash
bash 11_Projects/linux-system-health-monitor/health_check.sh
bash 11_Projects/linux-system-health-monitor/health_check.sh --help
bash 11_Projects/linux-system-health-monitor/health_check.sh --self-test
bash 11_Projects/linux-system-health-monitor/health_check.sh --meminfo /path/to/meminfo
bash 11_Projects/linux-system-health-monitor/test_health_check.sh
```

`--meminfo FILE` explicitly reads the supplied memory data instead of invoking `free`, which makes reports deterministic for fixtures and portable across systems. Unknown arguments, extra arguments, and a missing file path return exit status 2 and print usage to standard error.
