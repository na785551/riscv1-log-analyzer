# RISC-V Simulation Log Analyzer

## Description
# RISC-V Simulation Log Analyzer
RISC-V Simulation Log Analyzer is a shell-based tool that processes RISC-V simulation log files and generates useful summary reports.
A Bash-based tool for analyzing RISC-V simulation logs.

The project was developed as the MEDS Module 1 Grand Assignment and demonstrates Linux commands, Bash scripting, Git workflows, and Makefiles.

## Features

- Counts total tests
- Counts PASS, FAIL, and SKIP results
- Calculates pass, fail, and skip percentages
- Lists failed test names
- Extracts execution times
- Calculates minimum, maximum, and average execution time
- Supports text and CSV output
- Supports output files
- Provides verbose mode
- Returns exit code 0 when all tests pass
- Returns exit code 1 when any test fails

## Project Structure

```text
riscv-log-analyzer/
├── README.md
├── Makefile
├── .gitignore
├── scripts/
│   ├── analyze.sh
│   ├── setup_env.sh
│   └── generate_report.sh
├── test_data/
│   ├── sample_sim.log
│   ├── sample_pass.log
│   └── sample_fail.log
├── output/
└── docs/
    └── USAGE.md
