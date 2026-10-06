# RISC-V Log Analyzer - Usage Guide

## 1. Overview

The RISC-V Log Analyzer is a Bash-based tool that analyzes RISC-V simulation log files.

It extracts:

- Total number of tests
- Number of passed tests
- Number of failed tests
- Number of skipped tests
- Pass, fail, and skip rates
- Names of failed tests
- Minimum execution time
- Maximum execution time
- Average execution time

The analyzer supports both **text** and **CSV** output formats.

---

## 2. Project Structure

The project has the following structure:

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