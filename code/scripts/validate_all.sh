#!/bin/bash

# steps/step-01 … step-37 + masmorra_ascii: dart pub get + dart analyze --fatal-warnings

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS_DIR="$SCRIPT_DIR/../steps"
MAS_DIR="$SCRIPT_DIR/../masmorra_ascii"
TOTAL=0
PASSED=0
FAILED=0
FAILED_STEPS=()

if [ ! -d "$STEPS_DIR" ]; then
    echo -e "${RED}Error: Steps directory not found at $STEPS_DIR${NC}"
    exit 1
fi

echo "Starting validation (steps + masmorra_ascii)..."
echo "=================================="
echo ""

# Usar seq + printf: no bash 3.2 (macOS), {01..37} não mantém zero à esquerda.
for i in $(seq 1 37); do
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

    if dart analyze --fatal-warnings > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $STEP_NAME: PASS${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗ $STEP_NAME: dart analyze failed (run manually for details)${NC}"
        FAILED=$((FAILED + 1))
        FAILED_STEPS+=("$STEP_NAME")
    fi
done

echo ""
echo "--- masmorra_ascii ---"
TOTAL=$((TOTAL + 1))
if [ ! -d "$MAS_DIR" ]; then
    echo -e "${RED}✗ masmorra_ascii: directory not found at $MAS_DIR${NC}"
    FAILED=$((FAILED + 1))
    FAILED_STEPS+=("masmorra_ascii")
elif ! cd "$MAS_DIR"; then
    echo -e "${RED}✗ masmorra_ascii: Could not cd${NC}"
    FAILED=$((FAILED + 1))
    FAILED_STEPS+=("masmorra_ascii")
elif ! dart pub get > /dev/null 2>&1; then
    echo -e "${RED}✗ masmorra_ascii: dart pub get failed${NC}"
    FAILED=$((FAILED + 1))
    FAILED_STEPS+=("masmorra_ascii")
elif dart analyze --fatal-warnings > /dev/null 2>&1; then
    echo -e "${GREEN}✓ masmorra_ascii: PASS${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ masmorra_ascii: dart analyze failed${NC}"
    FAILED=$((FAILED + 1))
    FAILED_STEPS+=("masmorra_ascii")
fi

echo ""
echo "=================================="
echo "VALIDATION SUMMARY"
echo "=================================="
echo -e "Total packages:  $TOTAL"
echo -e "${GREEN}Passed:          $PASSED/$TOTAL${NC}"
echo -e "${RED}Failed:          $FAILED/$TOTAL${NC}"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}Failed:${NC}"
    for step in "${FAILED_STEPS[@]}"; do
        echo -e "  ${RED}• $step${NC}"
    done
    echo ""
    exit 1
else
    echo ""
    echo -e "${GREEN}All packages passed!${NC}"
    exit 0
fi
