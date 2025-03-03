#!/bin/bash

# Create temporary test directory
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

# Source files
list_file="../list"
inactive_file="../inactive"

# Test files
test_list_file="${TEST_DIR}/test_list"
test_inactive_file="${TEST_DIR}/test_inactive"

# Backup original files
cp "$list_file" "$test_list_file"
cp "$inactive_file" "$test_inactive_file"

# Test adding a new domain
./manage_domains.sh add "newdomain.com"
if grep -q "^newdomain.com$" "$test_list_file"; then
    echo "Test add domain: PASSED"
else
    echo "Test add domain: FAILED"
fi

# Test moving an inactive domain
./manage_domains.sh move "newdomain.com"
if grep -q "^newdomain.com$" "$test_inactive_file" && ! grep -q "^newdomain.com$" "$test_list_file"; then
    echo "Test move domain: PASSED"
else
    echo "Test move domain: FAILED"
fi

# Test maintaining file sorting and comments
./manage_domains.sh add "anotherdomain.com"
./manage_domains.sh move "anotherdomain.com"
if diff -u <(grep -v -E '^(#|$)' "$test_list_file" | sort) <(grep -v -E '^(#|$)' "$test_list_file") && \
   diff -u <(grep -v -E '^(#|$)' "$test_inactive_file" | sort) <(grep -v -E '^(#|$)' "$test_inactive_file"); then
    echo "Test file sorting and comments: PASSED"
else
    echo "Test file sorting and comments: FAILED"
fi

# Restore original files
mv "$test_list_file" "$list_file"
mv "$test_inactive_file" "$inactive_file"
