# Prompt Tool Versions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add categorized tool version display (lang/iac/ops/ai) with runtime color theming to the jasonchaffee zsh prompt.

**Architecture:** Single-file changes to `themes/jasonchaffee/jasonchaffee.zsh-theme`. New version functions follow existing pattern. Row functions aggregate tools per category. Config functions enable runtime customization. Tests in `tests/theme_test.zsh`.

**Tech Stack:** zsh, Oh My Zsh theme conventions

**Spec:** `docs/superpowers/specs/2026-03-29-prompt-tool-versions-design.md`

---

## File Structure

- Modify: `themes/jasonchaffee/jasonchaffee.zsh-theme` — all theme code
- Create: `tests/theme_test.zsh` — test suite
- Modify: `README.md` — documentation update

---

### Task 1: Test infrastructure + _clean_version

**Files:**
- Create: `tests/theme_test.zsh`
- Modify: `themes/jasonchaffee/jasonchaffee.zsh-theme` (add `_clean_version` at top)

- [ ] **Step 1: Create test harness**

```zsh
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `zsh tests/theme_test.zsh`
Expected: FAIL — `_clean_version` function not found

- [ ] **Step 3: Add config defaults and _clean_version to theme**

Add at the very top of `themes/jasonchaffee/jasonchaffee.zsh-theme`, before existing functions.

Also update existing language functions to wrap their version output with `_clean_version()`. For example, `go_prompt_info` becomes:

```zsh
function go_prompt_info() {
  if command -v go >/dev/null 2>&1; then
    local ver="$(go version 2>&1 | grep 'go version' | awk '{print $3}' | tr -d \go | tr -d \")"
    echo "$ZSH_THEME_GO_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_GO_PROMPT_SUFFIX"
  fi
}
```

Apply the same pattern to `java_prompt_info`, `node_prompt_info`, `python_prompt_info`, `ruby_prompt_info`, and `scala_prompt_info` — extract version into a local var, pass through `_clean_version`.

Config defaults and helper to add at top:

```zsh
# Configuration defaults
PROMPT_LABEL_COLOR=${PROMPT_LABEL_COLOR:-cyan}
PROMPT_TOOL_COLOR=${PROMPT_TOOL_COLOR:-yellow}
PROMPT_VERSION_COLOR=${PROMPT_VERSION_COLOR:-magenta}
PROMPT_LABEL_STYLE=${PROMPT_LABEL_STYLE:-text}
PROMPT_VERSION_MODE=${PROMPT_VERSION_MODE:-clean}
PROMPT_ORDER_MODE=${PROMPT_ORDER_MODE:-fixed}

# Known noise suffixes to strip in clean mode (not pre-release identifiers)
_KNOWN_NOISE_SUFFIXES=(-rd -dispatcher)

function _clean_version() {
  local ver="$1"
  [[ -z "$ver" ]] && return
  if [[ "$PROMPT_VERSION_MODE" == "raw" ]]; then
    echo "$ver"
    return
  fi
  # Strip leading v/V
  ver="${ver#[vV]}"
  # Strip +build metadata
  ver="${ver%%+*}"
  # Strip known noise suffixes
  for suffix in "${_KNOWN_NOISE_SUFFIXES[@]}"; do
    ver="${ver%$suffix}"
  done
  # Strip trailing dots
  ver="${ver%.}"
  echo "$ver"
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `zsh tests/theme_test.zsh`
Expected: All PASS

- [ ] **Step 5: Commit**

```bash
git add tests/theme_test.zsh themes/jasonchaffee/jasonchaffee.zsh-theme
git commit -m "feat: add _clean_version helper and test infrastructure"
```

---

### Task 2: IaC version functions (terraform, terragrunt, stubs)

**Files:**
- Modify: `tests/theme_test.zsh` (add iac tests)
- Modify: `themes/jasonchaffee/jasonchaffee.zsh-theme` (add functions)

- [ ] **Step 1: Add IaC tests**

Append to `tests/theme_test.zsh` before the Results line:

```zsh
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
```

- [ ] **Step 2: Run tests — verify fail**

Run: `zsh tests/theme_test.zsh`
Expected: FAIL — functions not defined

- [ ] **Step 3: Implement IaC functions**

Add after the existing language functions in the theme file:

```zsh
# --- IaC version functions ---

function terraform_prompt_info() {
  if command -v terraform >/dev/null 2>&1; then
    # Use -json for ~4x faster execution (avoids update check)
    # Output: {"terraform_version":"1.14.8",...}
    local ver="$(terraform version -json 2>&1 | grep terraform_version | awk -F'"' '{print $4}')"
    echo "$ZSH_THEME_TERRAFORM_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_TERRAFORM_PROMPT_SUFFIX"
  fi
}

function terragrunt_prompt_info() {
  if command -v terragrunt >/dev/null 2>&1; then
    # Output: "terragrunt version v0.99.5"
    local ver="$(terragrunt --version 2>&1 | head -1 | awk '{print $NF}')"
    echo "$ZSH_THEME_TERRAGRUNT_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_TERRAGRUNT_PROMPT_SUFFIX"
  fi
}

function pulumi_prompt_info() {
  if command -v pulumi >/dev/null 2>&1; then
    local ver="$(pulumi version 2>&1 | head -1)"
    echo "$ZSH_THEME_PULUMI_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_PULUMI_PROMPT_SUFFIX"
  fi
}

function ansible_prompt_info() {
  if command -v ansible >/dev/null 2>&1; then
    local ver="$(ansible --version 2>&1 | head -1 | awk '{print $NF}' | tr -d '[]')"
    echo "$ZSH_THEME_ANSIBLE_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_ANSIBLE_PROMPT_SUFFIX"
  fi
}

function packer_prompt_info() {
  if command -v packer >/dev/null 2>&1; then
    local ver="$(packer version 2>&1 | head -1 | awk '{print $2}')"
    echo "$ZSH_THEME_PACKER_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_PACKER_PROMPT_SUFFIX"
  fi
}
```

- [ ] **Step 4: Run tests — verify pass**

Run: `zsh tests/theme_test.zsh`
Expected: All PASS

- [ ] **Step 5: Commit**

```bash
git add tests/theme_test.zsh themes/jasonchaffee/jasonchaffee.zsh-theme
git commit -m "feat: add IaC version functions (terraform, terragrunt, stubs)"
```

---

### Task 3: Ops version functions (docker, helm, kubectl, k9s)

**Files:**
- Modify: `tests/theme_test.zsh`
- Modify: `themes/jasonchaffee/jasonchaffee.zsh-theme`

- [ ] **Step 1: Add ops tests**

Append to tests:

```zsh
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
```

- [ ] **Step 2: Run tests — verify fail**

Run: `zsh tests/theme_test.zsh`

- [ ] **Step 3: Implement ops functions**

```zsh
# --- Ops version functions ---

function docker_prompt_info() {
  if command -v docker >/dev/null 2>&1; then
    # Output: "Docker version 27.5.1-rd, build 0c97515" (client-side, no daemon)
    local ver="$(docker --version 2>&1 | awk '{print $3}' | tr -d ',')"
    echo "$ZSH_THEME_DOCKER_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_DOCKER_PROMPT_SUFFIX"
  fi
}

function helm_prompt_info() {
  if command -v helm >/dev/null 2>&1; then
    # Output: "v3.17.1+g980d8ac"
    local ver="$(helm version --short 2>&1)"
    echo "$ZSH_THEME_HELM_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_HELM_PROMPT_SUFFIX"
  fi
}

function kubectl_prompt_info() {
  if command -v kubectl >/dev/null 2>&1; then
    # Output format varies: v1.28+ uses "Client Version: vX.Y.Z"
    local ver="$(kubectl version --client 2>&1 | head -1 | awk '{print $NF}')"
    echo "$ZSH_THEME_KUBECTL_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_KUBECTL_PROMPT_SUFFIX"
  fi
}

function k9s_prompt_info() {
  if command -v k9s >/dev/null 2>&1; then
    # Output (--short is still multi-line): "Version  v0.50.18\nCommit ...\nDate ..."
    local ver="$(k9s version --short 2>&1 | grep 'Version' | awk '{print $2}')"
    echo "$ZSH_THEME_K9S_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_K9S_PROMPT_SUFFIX"
  fi
}
```

- [ ] **Step 4: Run tests — verify pass**

Run: `zsh tests/theme_test.zsh`

- [ ] **Step 5: Commit**

```bash
git add tests/theme_test.zsh themes/jasonchaffee/jasonchaffee.zsh-theme
git commit -m "feat: add ops version functions (docker, helm, kubectl, k9s)"
```

---

### Task 4: AI CLI version functions

**Files:**
- Modify: `tests/theme_test.zsh`
- Modify: `themes/jasonchaffee/jasonchaffee.zsh-theme`

- [ ] **Step 1: Add AI CLI tests**

```zsh
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
```

- [ ] **Step 2: Run tests — verify fail**

- [ ] **Step 3: Implement AI CLI functions**

```zsh
# --- AI CLI version functions ---

function claude_prompt_info() {
  if command -v claude >/dev/null 2>&1; then
    # Output: "2.1.87 (Claude Code)" — extract just the version number
    local ver="$(claude --version 2>&1 | head -1 | awk '{print $1}')"
    echo "$ZSH_THEME_CLAUDE_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_CLAUDE_PROMPT_SUFFIX"
  fi
}

function codex_prompt_info() {
  if command -v codex >/dev/null 2>&1; then
    # Output: "codex-cli 0.117.0"
    local ver="$(codex --version 2>&1 | head -1 | awk '{print $NF}')"
    echo "$ZSH_THEME_CODEX_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_CODEX_PROMPT_SUFFIX"
  fi
}

function gemini_prompt_info() {
  if command -v gemini >/dev/null 2>&1; then
    local ver="$(gemini --version 2>&1 | head -1)"
    echo "$ZSH_THEME_GEMINI_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_GEMINI_PROMPT_SUFFIX"
  fi
}

function copilot_prompt_info() {
  # Use 'gh extension list' for detection (~93ms vs ~862ms for 'gh copilot --version')
  if command -v gh >/dev/null 2>&1 && gh extension list 2>/dev/null | grep -q copilot; then
    # Output: "GitHub Copilot CLI 0.0.422."
    local ver="$(gh copilot --version 2>&1 | head -1 | awk '{print $NF}')"
    echo "$ZSH_THEME_COPILOT_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_COPILOT_PROMPT_SUFFIX"
  fi
}

function cursor_prompt_info() {
  if command -v cursor >/dev/null 2>&1; then
    # Output: "2.6.21\n<commit-hash>\n<arch>" — head -1 grabs just the version
    local ver="$(cursor --version 2>&1 | head -1)"
    echo "$ZSH_THEME_CURSOR_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_CURSOR_PROMPT_SUFFIX"
  fi
}
```

- [ ] **Step 4: Run tests — verify pass**

- [ ] **Step 5: Commit**

```bash
git add tests/theme_test.zsh themes/jasonchaffee/jasonchaffee.zsh-theme
git commit -m "feat: add AI CLI version functions (claude, codex, gemini, copilot, cursor)"
```

---

### Task 5: Row functions + ordering

**Files:**
- Modify: `tests/theme_test.zsh`
- Modify: `themes/jasonchaffee/jasonchaffee.zsh-theme`

- [ ] **Step 1: Add row function tests**

```zsh
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
```

- [ ] **Step 2: Run tests — verify fail**

- [ ] **Step 3: Implement row functions**

```zsh
# --- Row functions ---

# Helper: build a row from tool outputs, applying label and ordering
function _build_row() {
  local category="$1"
  shift
  local -a items=()

  while [[ $# -gt 0 ]]; do
    local output="$1"
    if [[ -n "$output" ]]; then
      items+=("$output")
    fi
    shift
  done

  [[ ${#items[@]} -eq 0 ]] && return

  if [[ "$PROMPT_ORDER_MODE" == "alpha" ]]; then
    # Strip color codes for sorting, then restore. Use a simple approach:
    # sort by the text between first [ and first : in each item
    items=($(printf '%s\n' "${items[@]}" | sort -t'[' -k2))
  fi

  local label=""
  case "$PROMPT_LABEL_STYLE" in
    text)
      # Pad labels to 5 chars (length of "lang:") so brackets align
      local -A text_labels=(lang "lang:" iac "iac: " ops "ops: " ai "ai:  ")
      if [[ "$TERM" != "dumb" ]] && [[ "$DISABLE_LS_COLORS" != "true" ]]; then
        label="%{$fg[$PROMPT_LABEL_COLOR]%}${text_labels[$category]}%{$reset_color%}"
      else
        label="${text_labels[$category]}"
      fi
      ;;
    emoji)
      local -A emoji_labels=(lang "📘" iac "🏗" ops "📦" ai "🤖")
      label="${emoji_labels[$category]}"
      ;;
    none) label="" ;;
  esac

  echo "${label} ${(j: :)items}"
}

function lang_row_info() {
  _build_row lang \
    "$(java_prompt_info)" "$(scala_prompt_info)" "$(go_prompt_info)" \
    "$(node_prompt_info)" "$(python_prompt_info)" "$(ruby_prompt_info)"
}

function iac_row_info() {
  _build_row iac \
    "$(terraform_prompt_info)" "$(terragrunt_prompt_info)" \
    "$(pulumi_prompt_info)" "$(ansible_prompt_info)" "$(packer_prompt_info)"
}

function ops_row_info() {
  _build_row ops \
    "$(docker_prompt_info)" "$(helm_prompt_info)" \
    "$(kubectl_prompt_info)" "$(k9s_prompt_info)"
}

function ai_row_info() {
  _build_row ai \
    "$(claude_prompt_info)" "$(codex_prompt_info)" \
    "$(gemini_prompt_info)" "$(copilot_prompt_info)" "$(cursor_prompt_info)"
}
```

- [ ] **Step 4: Run tests — verify pass**

- [ ] **Step 5: Commit**

```bash
git add tests/theme_test.zsh themes/jasonchaffee/jasonchaffee.zsh-theme
git commit -m "feat: add row functions with label styles and ordering"
```

---

### Task 6: Configuration functions + _update_theme_colors

**Files:**
- Modify: `tests/theme_test.zsh`
- Modify: `themes/jasonchaffee/jasonchaffee.zsh-theme`

- [ ] **Step 1: Add config tests**

```zsh
echo "=== Configuration function tests ==="

prompt_theme default
assert_eq "theme default label" "cyan" "$PROMPT_LABEL_COLOR"
assert_eq "theme default tool" "yellow" "$PROMPT_TOOL_COLOR"
assert_eq "theme default version" "magenta" "$PROMPT_VERSION_COLOR"

prompt_theme ocean
assert_eq "theme ocean label" "blue" "$PROMPT_LABEL_COLOR"
assert_eq "theme ocean tool" "cyan" "$PROMPT_TOOL_COLOR"
assert_eq "theme ocean version" "green" "$PROMPT_VERSION_COLOR"

prompt_colors label red
assert_eq "colors slot override" "red" "$PROMPT_LABEL_COLOR"

prompt_colors green yellow blue
assert_eq "colors positional label" "green" "$PROMPT_LABEL_COLOR"
assert_eq "colors positional tool" "yellow" "$PROMPT_TOOL_COLOR"
assert_eq "colors positional version" "blue" "$PROMPT_VERSION_COLOR"

prompt_labels emoji
assert_eq "labels emoji" "emoji" "$PROMPT_LABEL_STYLE"

prompt_versions raw
assert_eq "versions raw" "raw" "$PROMPT_VERSION_MODE"

prompt_order alpha
assert_eq "order alpha" "alpha" "$PROMPT_ORDER_MODE"

# Test invalid inputs return error
prompt_theme bogus 2>/dev/null
assert_eq "invalid theme returns error" "1" "$?"
prompt_order bogus 2>/dev/null
assert_eq "invalid order returns error" "1" "$?"
prompt_labels bogus 2>/dev/null
assert_eq "invalid labels returns error" "1" "$?"

# Reset
prompt_theme default
prompt_labels text
prompt_versions clean
prompt_order fixed
```

- [ ] **Step 2: Run tests — verify fail**

- [ ] **Step 3: Implement config functions and _update_theme_colors**

```zsh
# --- Configuration functions ---

# Prefix constants for new tools
TERRAFORM_PROMPT_PREFIX=tf
TERRAGRUNT_PROMPT_PREFIX=tg
DOCKER_PROMPT_PREFIX=docker
HELM_PROMPT_PREFIX=helm
KUBECTL_PROMPT_PREFIX=k8s
K9S_PROMPT_PREFIX=k9s
CLAUDE_PROMPT_PREFIX=claude
CODEX_PROMPT_PREFIX=codex
GEMINI_PROMPT_PREFIX=gemini
COPILOT_PROMPT_PREFIX=copilot
CURSOR_PROMPT_PREFIX=cursor
PULUMI_PROMPT_PREFIX=pulumi
ANSIBLE_PROMPT_PREFIX=ansible
PACKER_PROMPT_PREFIX=packer

function _update_theme_colors() {
  if [[ "$TERM" != "dumb" ]] && [[ "$DISABLE_LS_COLORS" != "true" ]]; then
    local tc="%{$fg[$PROMPT_TOOL_COLOR]%}"
    local vc="%{$fg[$PROMPT_VERSION_COLOR]%}"
    local rc="%{$reset_color%}"

    # Update existing language PREFIX/SUFFIX
    if command -v java >/dev/null 2>&1; then
      ZSH_THEME_JAVA_PROMPT_PREFIX=" [${tc}$(java_prompt_prefix)${rc}:${vc}"
      ZSH_THEME_JAVA_PROMPT_SUFFIX="${rc}]"
    else
      ZSH_THEME_JAVA_PROMPT_PREFIX=""
      ZSH_THEME_JAVA_PROMPT_SUFFIX=""
    fi
    local -A lang_tools=(GO go NODE node SCALA scala PYTHON py RUBY rb)
    local -A lang_cmds=(GO go NODE node SCALA scala PYTHON python3 RUBY ruby)
    for uname label in ${(kv)lang_tools}; do
      local cmd="${lang_cmds[$uname]}"
      if command -v "$cmd" >/dev/null 2>&1; then
        eval "ZSH_THEME_${uname}_PROMPT_PREFIX=\" [${tc}${label}${rc}:${vc}% \""
        eval "ZSH_THEME_${uname}_PROMPT_SUFFIX=\"${rc}]\""
      else
        eval "ZSH_THEME_${uname}_PROMPT_PREFIX=\"\""
        eval "ZSH_THEME_${uname}_PROMPT_SUFFIX=\"\""
      fi
    done

    # Set PREFIX/SUFFIX for all new tools
    local -A new_tools=(TERRAFORM terraform TERRAGRUNT terragrunt DOCKER docker
      HELM helm KUBECTL kubectl K9S k9s CLAUDE claude CODEX codex
      GEMINI gemini COPILOT gh CURSOR cursor PULUMI pulumi ANSIBLE ansible PACKER packer)
    for t cmd in ${(kv)new_tools}; do
      local pref_var="${t}_PROMPT_PREFIX"
      local label="${(P)pref_var}"
      if command -v "$cmd" >/dev/null 2>&1; then
        eval "ZSH_THEME_${t}_PROMPT_PREFIX=\" [${tc}${label}${rc}:${vc}% \""
        eval "ZSH_THEME_${t}_PROMPT_SUFFIX=\"${rc}]\""
      else
        eval "ZSH_THEME_${t}_PROMPT_PREFIX=\"\""
        eval "ZSH_THEME_${t}_PROMPT_SUFFIX=\"\""
      fi
    done
  else
    # Dumb terminal — no colors, same guard logic
    local -A new_tools=(TERRAFORM terraform TERRAGRUNT terragrunt DOCKER docker
      HELM helm KUBECTL kubectl K9S k9s CLAUDE claude CODEX codex
      GEMINI gemini COPILOT gh CURSOR cursor PULUMI pulumi ANSIBLE ansible PACKER packer)
    for t cmd in ${(kv)new_tools}; do
      local pref_var="${t}_PROMPT_PREFIX"
      local label="${(P)pref_var}"
      if command -v "$cmd" >/dev/null 2>&1; then
        eval "ZSH_THEME_${t}_PROMPT_PREFIX=\" [${label}:\""
        eval "ZSH_THEME_${t}_PROMPT_SUFFIX=\"]\""
      else
        eval "ZSH_THEME_${t}_PROMPT_PREFIX=\"\""
        eval "ZSH_THEME_${t}_PROMPT_SUFFIX=\"\""
      fi
    done
  fi
}

function prompt_theme() {
  case "$1" in
    default) PROMPT_LABEL_COLOR=cyan;  PROMPT_TOOL_COLOR=yellow; PROMPT_VERSION_COLOR=magenta ;;
    ocean)   PROMPT_LABEL_COLOR=blue;  PROMPT_TOOL_COLOR=cyan;   PROMPT_VERSION_COLOR=green ;;
    warm)    PROMPT_LABEL_COLOR=red;   PROMPT_TOOL_COLOR=yellow; PROMPT_VERSION_COLOR=green ;;
    mono)    PROMPT_LABEL_COLOR=white; PROMPT_TOOL_COLOR=white;  PROMPT_VERSION_COLOR=white ;;
    matrix)  PROMPT_LABEL_COLOR=green; PROMPT_TOOL_COLOR=green;  PROMPT_VERSION_COLOR=cyan ;;
    *) echo "Usage: prompt_theme <default|ocean|warm|mono|matrix>"; return 1 ;;
  esac
  _update_theme_colors
}

function prompt_colors() {
  case $# in
    2)
      case "$1" in
        label)   PROMPT_LABEL_COLOR="$2" ;;
        tool)    PROMPT_TOOL_COLOR="$2" ;;
        version) PROMPT_VERSION_COLOR="$2" ;;
        *) echo "Usage: prompt_colors <label|tool|version> <color>"; return 1 ;;
      esac
      ;;
    3)
      PROMPT_LABEL_COLOR="$1"
      PROMPT_TOOL_COLOR="$2"
      PROMPT_VERSION_COLOR="$3"
      ;;
    *) echo "Usage: prompt_colors <label|tool|version> <color>"; echo "       prompt_colors <label> <tool> <version>"; return 1 ;;
  esac
  _update_theme_colors
}

function prompt_labels() {
  case "$1" in
    text|emoji|none) PROMPT_LABEL_STYLE="$1" ;;
    *) echo "Usage: prompt_labels <text|emoji|none>"; return 1 ;;
  esac
}

function prompt_versions() {
  case "$1" in
    clean|raw) PROMPT_VERSION_MODE="$1" ;;
    *) echo "Usage: prompt_versions <clean|raw>"; return 1 ;;
  esac
}

function prompt_order() {
  case "$1" in
    fixed|alpha) PROMPT_ORDER_MODE="$1" ;;
    *) echo "Usage: prompt_order <fixed|alpha>"; return 1 ;;
  esac
}
```

- [ ] **Step 4: Run tests — verify pass**

- [ ] **Step 5: Commit**

```bash
git add tests/theme_test.zsh themes/jasonchaffee/jasonchaffee.zsh-theme
git commit -m "feat: add configuration functions and _update_theme_colors"
```

---

### Task 7: Update prompt functions (prompt_one through prompt_four)

**Files:**
- Modify: `tests/theme_test.zsh`
- Modify: `themes/jasonchaffee/jasonchaffee.zsh-theme`

- [ ] **Step 1: Add prompt integration tests**

```zsh
echo "=== Prompt integration tests ==="
prompt_theme default
prompt_labels text

# Verify prompt template strings contain row function calls
local p3="$(prompt_three)"
assert_eq "prompt_three has lang_row_info" true "$( [[ "$p3" == *'lang_row_info'* ]] && echo true || echo false )"
assert_eq "prompt_three has iac_row_info" true "$( [[ "$p3" == *'iac_row_info'* ]] && echo true || echo false )"
assert_eq "prompt_three has ops_row_info" true "$( [[ "$p3" == *'ops_row_info'* ]] && echo true || echo false )"
assert_eq "prompt_three has ai_row_info" true "$( [[ "$p3" == *'ai_row_info'* ]] && echo true || echo false )"

# Verify old individual calls are removed
assert_eq "prompt_three no java_prompt_info" true "$( [[ "$p3" != *'java_prompt_info'* ]] && echo true || echo false )"

# Verify rows actually render (functional test)
local lang_rendered="$(lang_row_info)"
assert_eq "lang row renders" true "$( [[ -n "$lang_rendered" ]] && echo true || echo false )"
```

- [ ] **Step 2: Run tests — verify fail**

- [ ] **Step 3: Update prompt functions**

Replace `prompt_one` through `prompt_four` in the theme. Use a helper to avoid blank lines from empty categories:

```zsh
# Helper: emit string with leading newline only if non-empty
function _nl_if() {
  local output="$1"
  [[ -n "$output" ]] && echo "\n${output}"
}

function prompt_one() {
  echo '$(return_prompt_info)$(lang_row_info)$(iac_row_info)$(ops_row_info)$(ai_row_info)$(pwd_prompt_info)$(git_prompt_info)$(svn_prompt_info)$(user_privilege_prompt_info)'
}

function prompt_two() {
  echo '$(user_prompt_info)$(host_prompt_info)$(pwd_prompt_info)$(git_prompt_info)$(svn_prompt_info)
$(return_prompt_info)$(lang_row_info)$(_nl_if "$(iac_row_info)")$(_nl_if "$(ops_row_info)")$(_nl_if "$(ai_row_info)")$(user_privilege_prompt_info)'
}

function prompt_three() {
  echo '$(lang_row_info)$(_nl_if "$(iac_row_info)")$(_nl_if "$(ops_row_info)")$(_nl_if "$(ai_row_info)")
$(return_prompt_info)$(pwd_prompt_info)$(git_prompt_info)$(svn_prompt_info)$(user_privilege_prompt_info)'
}

function prompt_four() {
  echo '$(lang_row_info)$(_nl_if "$(iac_row_info)")$(_nl_if "$(ops_row_info)")$(_nl_if "$(ai_row_info)")
$(return_prompt_info)$(user_prompt_info)$(host_prompt_info)$(pwd_prompt_info)$(git_prompt_info)$(svn_prompt_info)$(user_privilege_prompt_info)'
}
```

- [ ] **Step 4: Remove old per-tool calls from prompt functions**

The old `$(java_prompt_info)$(scala_prompt_info)...` calls are replaced by `$(lang_row_info)`. Make sure no duplicates remain.

- [ ] **Step 5: Add initial _update_theme_colors call**

At the bottom of the theme file, after `PROMPT=$(prompt_three)`, add:

```zsh
_update_theme_colors
```

- [ ] **Step 6: Run tests — verify pass**

Run: `zsh tests/theme_test.zsh`

- [ ] **Step 7: Commit**

```bash
git add tests/theme_test.zsh themes/jasonchaffee/jasonchaffee.zsh-theme
git commit -m "feat: update prompt layouts to use categorized row functions"
```

---

### Task 8: Dumb terminal support for new tools

**Files:**
- Modify: `themes/jasonchaffee/jasonchaffee.zsh-theme`

- [ ] **Step 1: Update dumb terminal branch**

In the `else` branch (dumb terminal), add PREFIX/SUFFIX vars for all new tools following the existing colorless pattern:

```zsh
# In the else branch (dumb terminal):
for t label in TERRAFORM tf TERRAGRUNT tg DOCKER docker HELM helm \
    KUBECTL k8s K9S k9s CLAUDE claude CODEX codex GEMINI gemini \
    COPILOT copilot CURSOR cursor PULUMI pulumi ANSIBLE ansible PACKER packer; do
  eval "ZSH_THEME_${t}_PROMPT_PREFIX=\" [${label}:\""
  eval "ZSH_THEME_${t}_PROMPT_SUFFIX=\"]\""
done
```

- [ ] **Step 2: Run tests — verify pass**

Run: `zsh tests/theme_test.zsh`
(Tests already run with TERM=dumb)

- [ ] **Step 3: Commit**

```bash
git add themes/jasonchaffee/jasonchaffee.zsh-theme
git commit -m "feat: add dumb terminal support for new tool version displays"
```

---

### Task 9: Update README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update README theme section**

Replace the Theme section:

```markdown
## Theme

`jasonchaffee` - Custom prompt with categorized tool versions:

| Category | Label | Tools shown |
|---|---|---|
| Languages | `lang:` | Java, Scala, Go, Node, Python, Ruby |
| IaC | `iac:` | Terraform, Terragrunt (+ Pulumi, Ansible, Packer stubs) |
| Ops | `ops:` | Docker, Helm, kubectl, k9s |
| AI CLI | `ai:` | Claude Code, Codex, Gemini CLI, GitHub Copilot, Cursor |

Plus Git/SVN branch and status, current directory, time, and user privilege indicator.
Only installed tools are shown — missing tools are silently hidden.

### Prompt Layouts

Use `prompt_set 1|2|3|4` to switch layouts:
- `1` — single line (all categories inline)
- `2` — user/host on first line, tools + path below
- `3` — tools on top lines, path below (default)
- `4` — tools on top, user/host + path below

### Configuration

All config functions take effect immediately. Add to `.zshrc` to persist.

**Color themes:**
```zsh
prompt_theme default   # cyan/yellow/magenta
prompt_theme ocean     # blue/cyan/green
prompt_theme warm      # red/yellow/green
prompt_theme mono      # white/white/white
prompt_theme matrix    # green/green/cyan
```

**Individual colors** (red, green, yellow, blue, magenta, cyan, white):
```zsh
prompt_colors label blue       # change category label color
prompt_colors tool cyan        # change tool name color
prompt_colors version green    # change version color
prompt_colors cyan yellow magenta  # set all three
```

**Label styles:**
```zsh
prompt_labels text    # lang: iac: ops: ai: (default)
prompt_labels emoji   # 📘 🏗 📦 🤖
prompt_labels none    # no labels
```

**Version display:**
```zsh
prompt_versions clean  # strip noise (default)
prompt_versions raw    # show raw output
```

**Tool ordering:**
```zsh
prompt_order fixed   # logical grouping (default)
prompt_order alpha   # alphabetical within each category
```
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update README with new prompt categories and configuration"
```

---

### Task 10: Final push

- [ ] **Step 1: Run full test suite**

Run: `zsh tests/theme_test.zsh`
Expected: All PASS, 0 FAIL

- [ ] **Step 2: Push all commits**

```bash
git push
```

Note: Use `$MY_GITHUB_PAT` if credential mismatch occurs (see memory reference).
