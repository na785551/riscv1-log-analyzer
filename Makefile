.PHONY: all test report clean help setup

SHELL := /bin/bash

ANALYZER := ./scripts/analyze.sh
TEST_DIR := ./test_data
OUTPUT_DIR := ./output

all:
	@echo "Running analyzer on all test logs..."
	@for log in $(TEST_DIR)/*.log; do \
		echo ""; \
		echo "===== $$log ====="; \
		$(ANALYZER) "$$log" || true; \
	done

test:
	@echo "Testing sample_pass.log..."
	@$(ANALYZER) $(TEST_DIR)/sample_pass.log > /tmp/pass_test.txt
	@grep -q "Total tests: 6" /tmp/pass_test.txt
	@grep -q "Passed:      6" /tmp/pass_test.txt
	@grep -q "Verdict: PASS" /tmp/pass_test.txt
	@echo "PASS log test: OK"

	@echo "Testing sample_fail.log..."
	@$(ANALYZER) $(TEST_DIR)/sample_fail.log > /tmp/fail_test.txt || test $$? -eq 1
	@grep -q "Failed:      2" /tmp/fail_test.txt
	@grep -q "rv32i-sll" /tmp/fail_test.txt
	@grep -q "rv32i-beq" /tmp/fail_test.txt
	@grep -q "Verdict: FAIL" /tmp/fail_test.txt
	@echo "FAIL log test: OK"

	@echo "All tests passed."

report:
	@./scripts/generate_report.sh

clean:
	@echo "Removing generated output files..."
	@rm -f $(OUTPUT_DIR)/*.txt
	@rm -f $(OUTPUT_DIR)/*.csv
	@echo "Clean complete."

help:
	@echo "RISC-V Log Analyzer - Available Targets"
	@echo
	@echo "  make all     Run analyzer on all test logs"
	@echo "  make test    Run automated tests"
	@echo "  make report  Generate summary report"
	@echo "  make clean   Remove generated output files"
	@echo "  make setup   Check required tools"
	@echo "  make help    Show this help message"

setup:
	@./scripts/setup_env.sh