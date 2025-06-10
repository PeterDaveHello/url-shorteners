#!/bin/bash
set -euo pipefail

failures=0
export LC_ALL=C
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TEST_DIR=$(mktemp -d)
echo -e "${YELLOW}Creating temporary test directory: $TEST_DIR${NC}"
trap 'rm -rf "$TEST_DIR"' EXIT

echo -e "${YELLOW}Copying test files to temporary directory${NC}"
list_file="${SCRIPT_DIR}/../list"
inactive_file="${SCRIPT_DIR}/../inactive"

test_list_file="${TEST_DIR}/test_list"
test_inactive_file="${TEST_DIR}/test_inactive"

cp "$list_file" "$test_list_file"
cp "$inactive_file" "$test_inactive_file"

export LIST_FILE="$test_list_file"
export INACTIVE_FILE="$test_inactive_file"

# Test helper function
run_test() {
    local name="$1"
    local code="$2"
    if [ "$code" -eq 0 ]; then
        echo -e "${GREEN}Test $name: PASSED${NC}"
    else
        echo -e "${RED}Test $name: FAILED${NC}"
        failures=$((failures+1))
    fi
}

# Testing: Add domain
echo
echo -e "${YELLOW}Testing: Add domain${NC}"
"${SCRIPT_DIR}/../manage_domains.sh" add "newdomain.com"
run_test "add domain" "$(grep -q "^newdomain.com$" "$test_list_file"; echo $?)"
echo

# Testing: Add invalid domain
echo -e "${YELLOW}Testing: Add invalid domain${NC}"
if "${SCRIPT_DIR}/../manage_domains.sh" add "invalid..domain" 2>/dev/null; then
    run_test "reject invalid domain" 1
else
    run_test "reject invalid domain" 0
fi
echo

# Testing: Move domain to inactive
echo -e "${YELLOW}Testing: Move domain to inactive${NC}"
"${SCRIPT_DIR}/../manage_domains.sh" move "newdomain.com"
run_test "move domain" "$(grep -q "^newdomain.com$" "$test_inactive_file" && ! grep -q "^newdomain.com$" "$test_list_file"; echo $?)"
echo

# Testing: Move non-existent domain
echo -e "${YELLOW}Testing: Move non-existent domain${NC}"
if "${SCRIPT_DIR}/../manage_domains.sh" move "nonexistentdomain.com" 2>/dev/null; then
    run_test "graceful handling of non-existent domain" "$( ! grep -q "^nonexistentdomain.com$" "$test_inactive_file"; echo $?)"
else
    run_test "graceful handling of non-existent domain" 1
fi
echo

# Testing: File sorting and comment preservation
echo -e "${YELLOW}Testing: File sorting and comment preservation${NC}"
"${SCRIPT_DIR}/../manage_domains.sh" add "anotherdomain.com"
"${SCRIPT_DIR}/../manage_domains.sh" move "anotherdomain.com"
run_test "file sorting and comments" "$(diff -u <(grep -v -E '^(#|$)' "$test_list_file" | sort) <(grep -v -E '^(#|$)' "$test_list_file") && diff -u <(grep -v -E '^(#|$)' "$test_inactive_file" | sort) <(grep -v -E '^(#|$)' "$test_inactive_file"); echo $?)"
echo

# Testing: Comment preservation
echo -e "${YELLOW}Testing: Comment preservation${NC}"
orig_comments=$(grep '^#' "$list_file")
new_comments=$(grep '^#' "$test_list_file")
if [ "$orig_comments" = "$new_comments" ]; then
    echo -e "${GREEN}Test comment preservation (active): PASSED${NC}"
else
    echo -e "${RED}Test comment preservation (active): FAILED${NC}"
    failures=$((failures+1))
fi

orig_comments_inactive=$(grep '^#' "$inactive_file")
new_comments_inactive=$(grep '^#' "$test_inactive_file")
if [ "$orig_comments_inactive" = "$new_comments_inactive" ]; then
    echo -e "${GREEN}Test comment preservation (inactive): PASSED${NC}"
else
    echo -e "${RED}Test comment preservation (inactive): FAILED${NC}"
    failures=$((failures+1))
fi

echo
echo -e "${YELLOW}Test summary:${NC}"
if [ "$failures" -eq 0 ]; then
    echo -e "${GREEN}All tests passed${NC}"
else
    echo -e "${RED}$failures tests failed${NC}"
fi

exit "$failures"
