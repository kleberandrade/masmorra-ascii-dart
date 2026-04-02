#!/bin/bash

# Percorre steps/step-01 … step-36: dart pub get + dart analyze

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS_DIR="$SCRIPT_DIR/../steps"
TOTAL=0
PASSED=0
FAILED=0
FAILED_STEPS=()

if [ ! -d "$STEPS_DIR" ]; then
    echo -e "${RED}Error: Steps directory not found at $STEPS_DIR${NC}"
    exit 1
fi

echo "Starting validation of all steps..."
echo "=================================="
echo ""

# Usar seq + printf: no bash 3.2 (macOS), {01..36} não mantém zero à esquerda.
for i in $(seq 1 36); do
    pad=$(printf '%02d' "$i")
    STEP_DIR="$STEPS_DIR/step-$pad"
    STEP_NAME="step-$pad"

    if [ ! -d "$STEP_DIR" ]; then
        echo -e "${YELLOW}⊘ $STEP_NAME: Directory not found${NC}"
        continue
    fi

    TOTAL=$((TOTAL + 1))

    cd "$STEP_DIR" || {
        echo -e "${RED}✗ $STEP_NAME: Could not cd into directory${NC}"
        FAILED=$((FAILED + 1))
        FAILED_STEPS+=("$STEP_NAME")
        continue
    }

    if ! dart pub get > /dev/null 2>&1; then
        echo -e "${RED}✗ $STEP_NAME: dart pub get failed${NC}"
        FAILED=$((FAILED + 1))
        FAILED_STEPS+=("$STEP_NAME")
        continue
    fi

    if dart analyze 2>&1 | grep -q "error:"; then
        echo -e "${RED}✗ $STEP_NAME: dart analyze found errors${NC}"
        FAILED=$((FAILED + 1))
        FAILED_STEPS+=("$STEP_NAME")
    else
        echo -e "${GREEN}✓ $STEP_NAME: PASS${NC}"
        PASSED=$((PASSED + 1))
    fi
done

echo ""
echo "=================================="
echo "VALIDATION SUMMARY"
echo "=================================="
echo -e "Total steps:  $TOTAL"
echo -e "${GREEN}Passed:      $PASSED/$TOTAL${NC}"
echo -e "${RED}Failed:      $FAILED/$TOTAL${NC}"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}Failed steps:${NC}"
    for step in "${FAILED_STEPS[@]}"; do
        echo -e "  ${RED}• $step${NC}"
    done
    echo ""
    exit 1
else
    echo ""
    echo -e "${GREEN}All steps passed!${NC}"
    exit 0
fi
