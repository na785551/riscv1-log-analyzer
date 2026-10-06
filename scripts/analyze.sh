#!/bin/bash

# Stop on errors, unset variables, and failed commands in pipelines.
set -euo pipefail

# Default options
FORMAT="text"
OUTPUT=""
VERBOSE=false
LOG_FILE=""

usage() {
    cat <<EOF
Usage: $0 <log_file> [OPTIONS]

Options:
  --format [text|csv]   Output format (default: text)
  --output <path>       Write output to a file instead of stdout
  --verbose             Enable verbose output
  --help                Show this help message

Examples:
  $0 test_data/sample_fail.log
  $0 test_data/sample_fail.log --format csv
  $0 test_data/sample_fail.log --output output/report.txt
EOF
}

error() {
    echo "Error: $1" >&2
    exit 1
}

# Check that all required commands are available.
check_dependencies() {
    local tools=("grep" "awk" "sed" "date")

    for tool in "${tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            error "Required command '$tool' is not installed."
        fi
    done
}

# Analyze the log and calculate test statistics.
analyze_log() {
    local file="$1"

    TOTAL=$(grep -c "TEST \(PASS\|FAIL\|SKIP\):" "$file" || true)
    PASSED=$(grep -c "TEST PASS:" "$file" || true)
    FAILED=$(grep -c "TEST FAIL:" "$file" || true)
    SKIPPED=$(grep -c "TEST SKIP:" "$file" || true)

    if [[ "$TOTAL" -gt 0 ]]; then
        PASS_RATE=$(awk -v p="$PASSED" -v t="$TOTAL" 'BEGIN { printf "%.1f", (p/t)*100 }')
        FAIL_RATE=$(awk -v f="$FAILED" -v t="$TOTAL" 'BEGIN { printf "%.1f", (f/t)*100 }')
        SKIP_RATE=$(awk -v s="$SKIPPED" -v t="$TOTAL" 'BEGIN { printf "%.1f", (s/t)*100 }')
    else
        PASS_RATE="0.0"
        FAIL_RATE="0.0"
        SKIP_RATE="0.0"
    fi

    # Extract failed test names from TEST FAIL lines.
    FAILED_TESTS=$(grep "TEST FAIL:" "$file" | sed -E 's/.*TEST FAIL: ([^ ]+).*/\1/' || true)

    # Extract execution times and calculate min, max, and average.
    TIMES=$(grep -E "TEST (PASS|FAIL):.*\([0-9]+(\.[0-9]+)?s\)" "$file" \
        | sed -E 's/.*\(([0-9]+(\.[0-9]+)?)s\).*/\1/' || true)

    if [[ -n "$TIMES" ]]; then
        MIN_TIME=$(echo "$TIMES" | awk 'NR==1 {min=$1} $1<min {min=$1} END {printf "%.2f", min}')
        MAX_TIME=$(echo "$TIMES" | awk 'NR==1 {max=$1} $1>max {max=$1} END {printf "%.2f", max}')
        AVG_TIME=$(echo "$TIMES" | awk '{sum+=$1; count++} END {if(count>0) printf "%.2f", sum/count}')
    else
        MIN_TIME="N/A"
        MAX_TIME="N/A"
        AVG_TIME="N/A"
    fi
}

# Generate human-readable text output.
generate_text_report() {
    echo "=== RISC-V Simulation Log Analysis ==="
    echo "Log file: $LOG_FILE"
    echo "Analysis date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo
    echo "--- Results Summary ---"
    echo "Total tests: $TOTAL"
    printf "Passed:      %d (%.1f%%)\n" "$PASSED" "$PASS_RATE"
    printf "Failed:      %d (%.1f%%)\n" "$FAILED" "$FAIL_RATE"
    printf "Skipped:     %d (%.1f%%)\n" "$SKIPPED" "$SKIP_RATE"
    echo

    echo "--- Failed Tests ---"

    if [[ "$FAILED" -eq 0 ]]; then
        echo "None"
    else
        local count=1
        while IFS= read -r test; do
            [[ -z "$test" ]] && continue
            echo "  $count. $test"
            ((count++))
        done <<< "$FAILED_TESTS"
    fi

    echo
    echo "--- Timing Statistics ---"
    echo "Timing samples: $(echo "$TIMES" | wc -l)"
    echo "Min time:  ${MIN_TIME}s"
    echo "Max time:  ${MAX_TIME}s"
    echo "Avg time:  ${AVG_TIME}s"
    echo

    if [[ "$FAILED" -eq 0 ]]; then
        echo "--- Verdict: PASS ---"
    else
        echo "--- Verdict: FAIL ---"
    fi
}

# Generate CSV output.
generate_csv_report() {
    echo "metric,value"
    echo "total_tests,$TOTAL"
    echo "passed,$PASSED"
    echo "failed,$FAILED"
    echo "skipped,$SKIPPED"
    echo "pass_rate,$PASS_RATE"
    echo "fail_rate,$FAIL_RATE"
    echo "skip_rate,$SKIP_RATE"
    echo "min_time,$MIN_TIME"
    echo "max_time,$MAX_TIME"
    echo "avg_time,$AVG_TIME"

    if [[ "$FAILED" -gt 0 ]]; then
        while IFS= read -r test; do
            [[ -z "$test" ]] && continue
            echo "failed_test,$test"
        done <<< "$FAILED_TESTS"
    fi
}

# Parse command-line arguments.
if [[ "$#" -eq 0 ]]; then
    usage
    exit 1
fi

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --help)
            usage
            exit 0
            ;;
        --format)
            [[ "$#" -ge 2 ]] || error "Missing format value."
            FORMAT="$2"
            shift 2
            ;;
        --output)
            [[ "$#" -ge 2 ]] || error "Missing output path."
            OUTPUT="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --*)
            error "Unknown option: $1"
            ;;
        *)
            if [[ -z "$LOG_FILE" ]]; then
                LOG_FILE="$1"
            else
                error "Unexpected argument: $1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$LOG_FILE" ]]; then
    error "Log file is required."
fi

if [[ ! -f "$LOG_FILE" ]]; then
    error "Log file '$LOG_FILE' does not exist."
fi

if [[ "$FORMAT" != "text" && "$FORMAT" != "csv" ]]; then
    error "Format must be 'text' or 'csv'."
fi

check_dependencies

if [[ "$VERBOSE" == true ]]; then
    echo "Analyzing: $LOG_FILE" >&2
fi

analyze_log "$LOG_FILE"

if [[ "$FORMAT" == "text" ]]; then
    if [[ -n "$OUTPUT" ]]; then
        generate_text_report > "$OUTPUT"
    else
        generate_text_report
    fi
else
    if [[ -n "$OUTPUT" ]]; then
        generate_csv_report > "$OUTPUT"
    else
        generate_csv_report
    fi
fi

# Return 1 when at least one test failed, as required by the assignment.
if [[ "$FAILED" -gt 0 ]]; then
    exit 1
fi

exit 0