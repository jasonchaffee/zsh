#!/usr/bin/env zsh
# tests/theme_test.zsh — test suite for jasonchaffee theme

PASS=0
FAIL=0

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    ((PASS++))
    echo "  PASS: $label"
  else
    ((FAIL++))
    echo "  FAIL: $label"
    echo "    expected: '$expected'"
    echo "    actual:   '$actual'"
  fi
}

assert_empty() {
  local label="$1" actual="$2"
  if [[ -z "$actual" ]]; then
    ((PASS++))
    echo "  PASS: $label"
  else
    ((FAIL++))
    echo "  FAIL: $label (expected empty, got '$actual')"
  fi
}

# Stub out zsh theme vars and oh-my-zsh functions to allow sourcing
typeset -A fg fg_bold
fg=(red '' green '' yellow '' blue '' magenta '' cyan '' white '')
fg_bold=(red '' green '' yellow '' blue '' magenta '' cyan '' white '')
reset_color=''
TERM=dumb
DISABLE_LS_COLORS=true

source "$(dirname "$0")/../themes/jasonchaffee/jasonchaffee.zsh-theme"

echo "=== _clean_version tests ==="
PROMPT_VERSION_MODE=clean
assert_eq "strips v prefix" "1.2.3" "$(_clean_version "v1.2.3")"
assert_eq "strips V prefix" "1.2.3" "$(_clean_version "V1.2.3")"
assert_eq "strips +build" "3.17.1" "$(_clean_version "v3.17.1+g980d8ac")"
assert_eq "strips -rd" "27.5.1" "$(_clean_version "27.5.1-rd")"
assert_eq "strips -dispatcher" "1.34.5" "$(_clean_version "v1.34.5-dispatcher")"
assert_eq "preserves -rc1" "1.2.3-rc1" "$(_clean_version "v1.2.3-rc1")"
assert_eq "preserves -beta.2" "1.0.0-beta.2" "$(_clean_version "v1.0.0-beta.2")"
assert_eq "strips trailing dot" "0.0.422" "$(_clean_version "0.0.422.")"
assert_eq "already clean" "2.1.86" "$(_clean_version "2.1.86")"
assert_eq "empty input" "" "$(_clean_version "")"

PROMPT_VERSION_MODE=raw
assert_eq "raw mode passthrough" "v1.2.3+build" "$(_clean_version "v1.2.3+build")"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
