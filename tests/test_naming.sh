#!/usr/bin/env bash
# test_naming.sh — End-to-end test for agent naming library.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../hooks"

PASS=0
FAIL=0

assert_eq() {
    local label="$1" expected="$2" actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        echo "PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $label (expected='$expected' actual='$actual')"
        FAIL=$((FAIL + 1))
    fi
}

assert_ne() {
    local label="$1" not_expected="$2" actual="$3"
    if [[ "$not_expected" != "$actual" ]]; then
        echo "PASS: $label (got '$actual', not '$not_expected')"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $label (got '$actual', should differ)"
        FAIL=$((FAIL + 1))
    fi
}

assert_contains() {
    local label="$1" needle="$2" haystack="$3"
    if [[ "$haystack" == *"$needle"* ]]; then
        echo "PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $label (expected to contain '$needle')"
        FAIL=$((FAIL + 1))
    fi
}

# Source library
source "$LIB_DIR/lib-naming.sh"

echo "=== Agent Naming Tests ==="
echo ""

# Test 1: Default theme is culture
theme=$(_name_active_theme)
assert_eq "Default theme is culture" "culture" "$theme"

# Test 2: Resolve known agent
name=$(_name_resolve "fd-safety")
assert_eq "fd-safety resolves to Lapsed Pacifist" "Lapsed Pacifist" "$name"

# Test 3: Resolve known agency
name=$(_name_resolve_agency "flux-drive")
assert_eq "flux-drive resolves to The Difficult Second Album" "The Difficult Second Album" "$name"

# Test 4: Unknown agent falls back to raw ID
name=$(_name_resolve "nonexistent-agent")
assert_eq "Unknown agent returns raw ID" "nonexistent-agent" "$name"

# Test 5: Unknown agency falls back to raw ID
name=$(_name_resolve_agency "nonexistent-agency")
assert_eq "Unknown agency returns raw ID" "nonexistent-agency" "$name"

# Test 6: Dispatch formatting with sequence
dispatch=$(_name_dispatch "fd-safety" 2 5)
assert_eq "Dispatch with sequence" "Lapsed Pacifist (2/5)" "$dispatch"

# Test 7: Dispatch formatting without sequence
dispatch=$(_name_dispatch "fd-safety")
assert_eq "Dispatch without sequence" "Lapsed Pacifist" "$dispatch"

# Test 8: Disabled mode returns raw ID
INTERNAME_DISABLED=1
name=$(_name_resolve "fd-safety")
assert_eq "Disabled returns raw ID" "fd-safety" "$name"
unset INTERNAME_DISABLED

# Test 9: Re-enabled after unset
name=$(_name_resolve "fd-safety")
assert_eq "Re-enabled resolves name" "Lapsed Pacifist" "$name"

# Test 10: _name_enabled check
_name_enabled && status=0 || status=$?
assert_eq "Enabled by default" "0" "$status"

INTERNAME_DISABLED=1
_name_enabled && status=0 || status=$?
assert_eq "Disabled when env set" "1" "$status"
unset INTERNAME_DISABLED

# Test 11: List agents returns content
list=$(_name_list)
line_count=$(echo "$list" | wc -l)
assert_ne "List has content" "0" "$line_count"
assert_contains "List contains fd-safety" "fd-safety" "$list"
assert_contains "List contains Lapsed Pacifist" "Lapsed Pacifist" "$list"

# Test 12: List agencies returns content
list=$(_name_list_agencies)
assert_contains "Agency list contains flux-drive" "flux-drive" "$list"

# Test 13: Multiple agents resolve to different names
name1=$(_name_resolve "fd-safety")
name2=$(_name_resolve "fd-correctness")
assert_ne "Different agents get different names" "$name1" "$name2"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
