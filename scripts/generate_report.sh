#!/bin/bash

# Stop on errors, unset variables, and failed pipelines.
set -euo pipefail

mkdir -p output

REPORT="output/report.html"

cat > "$REPORT" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RISC-V Simulation Report</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f5f5f5;
        }

        h1 {
            color: #222;
        }

        table {
            border-collapse: collapse;
            width: 100%;
            background-color: white;
        }

        th, td {
            border: 1px solid #ccc;
            padding: 10px;
            text-align: left;
        }

        th {
            background-color: #333;
            color: white;
        }

        .pass {
            color: green;
            font-weight: bold;
        }

        .fail {
            color: red;
            font-weight: bold;
        }

        .skip {
            color: orange;
            font-weight: bold;
        }
    </style>
</head>

<body>

<h1>RISC-V Simulation Test Report</h1>

<p>Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>

<table>

<tr>
    <th>Log File</th>
    <th>Total Tests</th>
    <th>Passed</th>
    <th>Failed</th>
    <th>Skipped</th>
    <th>Verdict</th>
</tr>
EOF

for log in test_data/*.log; do

    total=$(grep -cE "TEST (PASS|FAIL|SKIP):" "$log" || true)
    passed=$(grep -c "TEST PASS:" "$log" || true)
    failed=$(grep -c "TEST FAIL:" "$log" || true)
    skipped=$(grep -c "TEST SKIP:" "$log" || true)

    if [[ "$failed" -eq 0 ]]; then
        verdict="PASS"
        verdict_class="pass"
    else
        verdict="FAIL"
        verdict_class="fail"
    fi

    cat >> "$REPORT" <<EOF
<tr>
    <td>$log</td>
    <td>$total</td>
    <td class="pass">$passed</td>
    <td class="fail">$failed</td>
    <td class="skip">$skipped</td>
    <td class="$verdict_class">$verdict</td>
</tr>
EOF

done

cat >> "$REPORT" <<EOF

</table>

</body>
</html>
EOF

echo "HTML report generated: $REPORT"