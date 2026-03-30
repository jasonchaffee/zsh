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
echo "=== IaC version function tests ==="
PROMPT_VERSION_MODE=clean
if command -v terraform >/dev/null 2>&1; then
  local tf_out="$(terraform_prompt_info)"
  assert_eq "terraform non-empty" true "$( [[ -n "$tf_out" ]] && echo true || echo false )"
  assert_eq "terraform cleaned" true "$( [[ "$tf_out" != *'Terraform'* ]] && echo true || echo false )"
fi
if command -v terragrunt >/dev/null 2>&1; then
  local tg_out="$(terragrunt_prompt_info)"
  assert_eq "terragrunt non-empty" true "$( [[ -n "$tg_out" ]] && echo true || echo false )"
fi

echo "=== Ops version function tests ==="
PROMPT_VERSION_MODE=clean
if command -v docker >/dev/null 2>&1; then
  local dock_out="$(docker_prompt_info)"
  assert_eq "docker non-empty" true "$( [[ -n "$dock_out" ]] && echo true || echo false )"
fi
if command -v helm >/dev/null 2>&1; then
  local helm_out="$(helm_prompt_info)"
  assert_eq "helm no v prefix" true "$( [[ "$helm_out" != *'v'[0-9]* ]] && echo true || echo false )"
  assert_eq "helm no +build" true "$( [[ "$helm_out" != *'+'* ]] && echo true || echo false )"
fi
if command -v kubectl >/dev/null 2>&1; then
  local k_out="$(kubectl_prompt_info)"
  assert_eq "kubectl non-empty" true "$( [[ -n "$k_out" ]] && echo true || echo false )"
fi
if command -v k9s >/dev/null 2>&1; then
  local k9_out="$(k9s_prompt_info)"
  assert_eq "k9s non-empty" true "$( [[ -n "$k9_out" ]] && echo true || echo false )"
fi

echo "=== AI CLI version function tests ==="
PROMPT_VERSION_MODE=clean
if command -v claude >/dev/null 2>&1; then
  local cl_out="$(claude_prompt_info)"
  assert_eq "claude non-empty" true "$( [[ -n "$cl_out" ]] && echo true || echo false )"
fi
if command -v codex >/dev/null 2>&1; then
  local cx_out="$(codex_prompt_info)"
  assert_eq "codex no prefix" true "$( [[ "$cx_out" != *'codex-cli'* ]] && echo true || echo false )"
fi
if command -v gemini >/dev/null 2>&1; then
  local gm_out="$(gemini_prompt_info)"
  assert_eq "gemini non-empty" true "$( [[ -n "$gm_out" ]] && echo true || echo false )"
fi

echo ""
echo "=== Row function tests ==="
PROMPT_LABEL_STYLE=text
PROMPT_ORDER_MODE=fixed

# lang row should produce output (at least one lang is installed)
local lang_out="$(lang_row_info)"
assert_eq "lang row non-empty" true "$([[ -n "$lang_out" ]] && echo true || echo false)"
assert_eq "lang row has label" true "$([[ "$lang_out" == *'lang:'* ]] && echo true || echo false)"

# Test alpha ordering
PROMPT_ORDER_MODE=alpha
local lang_alpha="$(lang_row_info)"
assert_eq "lang alpha has label" true "$([[ "$lang_alpha" == *'lang:'* ]] && echo true || echo false)"

# Test no-label mode
PROMPT_LABEL_STYLE=none
local lang_nolabel="$(lang_row_info)"
assert_eq "lang no label" true "$([[ ! "$lang_nolabel" == *'lang:'* ]] && echo true || echo false)"

# Test empty row (mock missing category by testing _build_row directly)
local empty_row="$(_build_row iac "" "" "" "" "")"
assert_empty "empty row produces nothing" "$empty_row"

# Reset
PROMPT_LABEL_STYLE=text
PROMPT_ORDER_MODE=fixed

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
