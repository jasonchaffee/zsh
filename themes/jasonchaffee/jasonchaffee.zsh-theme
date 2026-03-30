# jasonchaffee.zsh-theme

# Currently used symbols:
# ⚡ ⏎ ✘ λ ✚ ✹ ✖ ➜ ═ ✭

# More symbols to choose from:
# ☀ ✹ ☄ ♆ ♀ ♁ ♐ ♇ ♈ ♉ ♚ ♛ ♜ ♝ ♞ ♟ ♠ ♣ ⚢ ⚲ ⚳ ⚴ ⚥ ⚤ ⚦ ⚒ ⚑ ⚐ ♺ ♻ ♼ ☰ ☱ ☲ ☳ ☴ ☵ ☶ ☷
# ✡ ✔ ✖ ✚ ✱ ✤ ✦ ❤ ➜ ➟ ➼ ✂ ✎ ✐ ⨀ ⨁ ⨂ ⨍ ⨎ ⨏ ⨷ ⩚ ⩛ ⩡ ⩱ ⩲ ⩵  ⩶ ⨠
# ⬅ ⬆ ⬇ ⬈ ⬉ ⬊ ⬋ ⬒ ⬓ ⬔ ⬕ ⬖ ⬗ ⬘ ⬙ ⬟  ⬤ 〒 ǀ ǁ ǂ ĭ Ť Ŧ
#  ±  ➦ ✘ ⚡ ⚙

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

function java_prompt_prefix() {
  if command -v javac >/dev/null 2>&1; then
    echo "jdk"
  elif command -v java >/dev/null 2>&1; then
    echo "jre"
  fi
}

function java_prompt_info() {
  if command -v java >/dev/null 2>&1; then
    local ver="$(java -version 2>&1 | grep -i -e 'java version' -e 'openjdk version' | awk '{print $3}' | tr -d \")"
    echo "$ZSH_THEME_JAVA_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_JAVA_PROMPT_SUFFIX"
  fi
}

function go_prompt_info() {
  if command -v go >/dev/null 2>&1; then
    local ver="$(go version 2>&1 | grep 'go version' | awk '{print $3}' | tr -d \go | tr -d \")"
    echo "$ZSH_THEME_GO_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_GO_PROMPT_SUFFIX"
  fi
}

function node_prompt_info() {
  if command -v node >/dev/null 2>&1; then
    if node --version >/dev/null 2>&1; then
      local ver="$(node --version)"
      echo "$ZSH_THEME_NODE_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_NODE_PROMPT_SUFFIX"
    fi
  fi
}

function python_prompt_info() {
  if command -v python3 >/dev/null 2>&1; then
    local ver="$(python3 -V 2>&1 | grep 'Python' | awk '{print $2}' | tr -d \")"
    echo "$ZSH_THEME_PYTHON_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_PYTHON_PROMPT_SUFFIX"
  elif command -v python >/dev/null 2>&1; then
    local ver="$(python -V 2>&1 | grep 'Python' | awk '{print $2}' | tr -d \")"
    echo "$ZSH_THEME_PYTHON_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_PYTHON_PROMPT_SUFFIX"
  fi
}

function ruby_prompt_info() {
  if command -v ruby >/dev/null 2>&1; then
    local ver="$(ruby --version 2>&1 | grep 'ruby' | awk '{print $2}' | tr -d \")"
    echo "$ZSH_THEME_RUBY_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_RUBY_PROMPT_SUFFIX"
  fi
}

function scala_prompt_info() {
  if command -v scala >/dev/null 2>&1; then
    local ver="$(scala -version 2>&1 | grep 'Scala code runner version' | awk '{print $5}' | tr -d \")"
    echo "$ZSH_THEME_SCALA_PROMPT_PREFIX$(_clean_version "$ver")$ZSH_THEME_SCALA_PROMPT_SUFFIX"
  fi
}

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
        eval "ZSH_THEME_${uname}_PROMPT_PREFIX=\" [${tc}${label}${rc}:${vc}\""
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
        eval "ZSH_THEME_${t}_PROMPT_PREFIX=\" [${tc}${label}${rc}:${vc}\""
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

function return_prompt_info() {
  echo "%(?.$ZSH_THEME_RETURN_PROMPT_SUCCESS_PREFIX$ZSH_THEME_RETURN_PROMPT_SUCCESS$ZSH_THEME_RETURN_PROMPT_SUCCESS_SUFFIX.$ZSH_THEME_RETURN_PROMPT_ERROR_PREFIX$ZSH_THEME_RETURN_PROMPT_ERROR$ZSH_THEME_RETURN_PROMPT_ERROR_SUFFIX)"
}

function user_privilege_prompt_info() {
  echo "%(!.$ZSH_THEME_USER_PROMPT_SUPER_PREFIX$ZSH_THEME_USER_PROMPT_SUPER$ZSH_THEME_USER_PROMPT_SUPER_SUFFIX.$ZSH_THEME_USER_PROMPT_NONSUPER_PREFIX$ZSH_THEME_USER_PROMPT_NONSUPER$ZSH_THEME_USER_PROMPT_NONSUPER_SUFFIX)"
}

function time_prompt_info() {
  echo "$ZSH_THEME_TIME_PROMPT_PREFIX%D{%L:%M:%S}$ZSH_THEME_TIME_PROMPT_SUFFIX"
}

function time_period_prompt_info() {
  echo "$ZSH_THEME_TIME_PERIOD_PROMPT_PREFIX%D{%p}$ZSH_THEME_TIME_PERIOD_PROMPT_SUFFIX"
}

function pwd_prompt_info() {
  echo "$ZSH_THEME_PWD_PROMPT_PREFIX$ZSH_THEME_PWD_PROMPT$ZSH_THEME_PWD_PROMPT_SUFFIX"
}

function user_prompt_info() {
  echo "$ZSH_THEME_USER_PROMPT_PREFIX$ZSH_THEME_USER_PROMPT$ZSH_THEME_USER_PROMPT_SUFFIX"
}

function host_prompt_info() {
  echo "$ZSH_THEME_HOST_PROMPT_PREFIX$ZSH_THEME_HOST_PROMPT$ZSH_THEME_HOST_PROMPT_SUFFIX"
}

function prompt_one() {
  echo '$(return_prompt_info)$(java_prompt_info)$(scala_prompt_info)$(go_prompt_info)$(node_prompt_info)$(python_prompt_info)$(ruby_prompt_info)$(pwd_prompt_info)$(git_prompt_info)$(svn_prompt_info)$(user_privilege_prompt_info)'
}

function prompt_two() {
  echo '$(user_prompt_info)$(host_prompt_info)$(pwd_prompt_info)$(git_prompt_info)$(svn_prompt_info)
$(return_prompt_info)$(java_prompt_info)$(scala_prompt_info)$(go_prompt_info)$(node_prompt_info)$(python_prompt_info)$(ruby_prompt_info)$(user_privilege_prompt_info)'
}

function prompt_three() {
  echo '$(java_prompt_info)$(scala_prompt_info)$(go_prompt_info)$(node_prompt_info)$(python_prompt_info)$(ruby_prompt_info)
$(return_prompt_info)$(pwd_prompt_info)$(git_prompt_info)$(svn_prompt_info)$(user_privilege_prompt_info)'
}

function prompt_four() {
  echo '$(java_prompt_info)$(scala_prompt_info)$(go_prompt_info)$(node_prompt_info)$(python_prompt_info)$(ruby_prompt_info)
$(return_prompt_info)$(user_prompt_info)$(host_prompt_info)$(pwd_prompt_info)$(git_prompt_info)$(svn_prompt_info)$(user_privilege_prompt_info)'
}

function prompt_set() {
  if [[ $1 == 1 ]]; then
    PROMPT=$(prompt_one)
  elif [[ $1 == 2 ]]; then
    PROMPT=$(prompt_two)
  elif [[ $1 == 3 ]]; then
    PROMPT=$(prompt_three)
  elif [[ $1 == 4 ]]; then
    PROMPT=$(prompt_four)
  else
    PROMPT=$(prompt_three)
  fi
}

PROMPT=$(prompt_three)

RPROMPT='$(git_prompt_status)$(svn_dirty)$(svn_dirty_pwd)$(time_prompt_info)$(time_period_prompt_info)'

GIT_PROMPT_PREFIX=git
SVN_PROMPT_PREFIX=svn

GO_PROMPT_PREFIX=go
NODE_PROMPT_PREFIX=node
PYTHON_PROMPT_PREFIX=py
RUBY_PROMPT_PREFIX=rb
SCALA_PROMPT_PREFIX=scala

if [[ "$TERM" != "dumb" ]] && [[ "$DISABLE_LS_COLORS" != "true" ]]; then
  ZSH_THEME_USER_PROMPT_PREFIX="%{$fg[yellow]%} "
  ZSH_THEME_USER_PROMPT="%n"
  ZSH_THEME_USER_PROMPT_SUFFIX="%{$reset_color%}@"

  ZSH_THEME_HOST_PROMPT_PREFIX="%{$fg[magenta]%}"
  ZSH_THEME_HOST_PROMPT="%m"
  ZSH_THEME_HOST_PROMPT_SUFFIX="%{$reset_color%} ➜ %{$reset_color%}"

  ZSH_THEME_PWD_PROMPT_PREFIX=" %{$fg[cyan]%}"
  ZSH_THEME_PWD_PROMPT="%10~"
  ZSH_THEME_PWD_PROMPT_SUFFIX="%{$reset_color%}"

  ZSH_THEME_RETURN_PROMPT_SUCCESS_PREFIX="%{$reset_color%}"
  ZSH_THEME_RETURN_PROMPT_SUCCESS="⏎"
  ZSH_THEME_RETURN_PROMPT_SUCCESS_SUFFIX="%{$reset_color%}"

  ZSH_THEME_RETURN_PROMPT_ERROR_PREFIX="%{$fg_bold[red]%}"
  ZSH_THEME_RETURN_PROMPT_ERROR="✘"
  ZSH_THEME_RETURN_PROMPT_ERROR_SUFFIX="%{$reset_color%}"

  if command -v java >/dev/null 2>&1; then
    ZSH_THEME_JAVA_PROMPT_PREFIX=" [%{$fg[yellow]%}$(java_prompt_prefix)%{$reset_color%}:%{$fg[magenta]%}% "
    ZSH_THEME_JAVA_PROMPT_SUFFIX="%{$reset_color%}]"
  else
    ZSH_THEME_JAVA_PROMPT_PREFIX=""
    ZSH_THEME_JAVA_PROMPT_SUFFIX=""
  fi

  if command -v go >/dev/null 2>&1; then
    ZSH_THEME_GO_PROMPT_PREFIX=" [%{$fg[yellow]%}$GO_PROMPT_PREFIX%{$reset_color%}:%{$fg[magenta]%}% "
    ZSH_THEME_GO_PROMPT_SUFFIX="%{$reset_color%}]"
  else
    ZSH_THEME_GO_PROMPT_PREFIX=""
    ZSH_THEME_GO_PROMPT_SUFFIX=""
  fi

  if command -v node >/dev/null 2>&1; then
    ZSH_THEME_NODE_PROMPT_PREFIX=" [%{$fg[yellow]%}$NODE_PROMPT_PREFIX%{$reset_color%}:%{$fg[magenta]%}% "
    ZSH_THEME_NODE_PROMPT_SUFFIX="%{$reset_color%}]"
  else
    ZSH_THEME_NODE_PROMPT_PREFIX=""
    ZSH_THEME_NODE_PROMPT_SUFFIX=""
  fi

  if command -v python3 >/dev/null 2>&1; then
    ZSH_THEME_PYTHON_PROMPT_PREFIX=" [%{$fg[yellow]%}$PYTHON_PROMPT_PREFIX%{$reset_color%}:%{$fg[magenta]%}% "
    ZSH_THEME_PYTHON_PROMPT_SUFFIX="%{$reset_color%}]"
  elif command -v python >/dev/null 2>&1; then
    ZSH_THEME_PYTHON_PROMPT_PREFIX=" [%{$fg[yellow]%}$PYTHON_PROMPT_PREFIX%{$reset_color%}:%{$fg[magenta]%}% "
    ZSH_THEME_PYTHON_PROMPT_SUFFIX="%{$reset_color%}]"
  else
    ZSH_THEME_PYTHON_PROMPT_PREFIX=""
    ZSH_THEME_PYTHON_PROMPT_SUFFIX=""
  fi

  if command -v ruby >/dev/null 2>&1; then
    ZSH_THEME_RUBY_PROMPT_PREFIX=" [%{$fg[yellow]%}$RUBY_PROMPT_PREFIX%{$reset_color%}:%{$fg[magenta]%}% "
    ZSH_THEME_RUBY_PROMPT_SUFFIX="%{$reset_color%}]"
  else
    ZSH_THEME_RUBY_PROMPT_PREFIX=""
    ZSH_THEME_RUBY_PROMPT_SUFFIX=""
  fi

  if command -v scala >/dev/null 2>&1; then
    ZSH_THEME_SCALA_PROMPT_PREFIX=" [%{$fg[yellow]%}$SCALA_PROMPT_PREFIX%{$reset_color%}:%{$fg[magenta]%}% "
    ZSH_THEME_SCALA_PROMPT_SUFFIX="%{$reset_color%}]"
  else
    ZSH_THEME_SCALA_PROMPT_PREFIX=""
    ZSH_THEME_SCALA_PROMPT_SUFFIX=""
  fi

  ZSH_THEME_USER_PROMPT_SUPER_PREFIX=" %{$fg_bold[red]%}"
  ZSH_THEME_USER_PROMPT_SUPER="⚡ λ"
  ZSH_THEME_USER_PROMPT_SUPER_SUFFIX=" %{$reset_color%}"

  ZSH_THEME_USER_PROMPT_NONSUPER_PREFIX=" %{$fg_bold[green]%}"
  ZSH_THEME_USER_PROMPT_NONSUPER="λ"
  ZSH_THEME_USER_PROMPT_NONSUPER_SUFFIX=" %{$reset_color%}"

  ZSH_THEME_TIME_PROMPT_PREFIX=" %{$fg[green]%}"
  ZSH_THEME_TIME_PROMPT_SUFFIX="%{$reset_color%}"

  ZSH_THEME_TIME_PERIOD_PROMPT_PREFIX=" %{$fg[yellow]%}"
  ZSH_THEME_TIME_PERIOD_PROMPT_SUFFIX="%{$reset_color%}"

  SVN_SHOW_BRANCH="true"
  ZSH_PROMPT_BASE_COLOR="%{$fg[yellow]%}"
  ZSH_THEME_SVN_PROMPT_PREFIX=" $SVN_PROMPT_PREFIX%{$reset_color%}:"
  ZSH_THEME_REPO_NAME_COLOR="%{$fg[magenta]%}"
  ZSH_THEME_SVN_PROMPT_DIRTY="%{$fg[blue]%} ✹"
  ZSH_THEME_SVN_PROMPT_CLEAN=""
  ZSH_THEME_SVN_PROMPT_DIRTY_PWD="%{$fg[blue]%} ✭"
  ZSH_THEME_SVN_PROMPT_CLEAN_PWD=""

  ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[yellow]%}$GIT_PROMPT_PREFIX%{$reset_color%}:%{$fg[magenta]%}"
  ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
  ZSH_THEME_GIT_PROMPT_DIRTY=""
  ZSH_THEME_GIT_PROMPT_CLEAN=""

  ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} ✚"
  ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} ✹"
  ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖"
  ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} ➜"
  ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} ═"
  ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭"
else
  ZSH_THEME_USER_PROMPT_PREFIX=""
  ZSH_THEME_USER_PROMPT="%n"
  ZSH_THEME_USER_PROMPT_SUFFIX="@"

  ZSH_THEME_HOST_PROMPT_PREFIX=""
  ZSH_THEME_HOST_PROMPT="%m"
  ZSH_THEME_HOST_PROMPT_SUFFIX=" ➜ "

  ZSH_THEME_PWD_PROMPT_PREFIX=" "
  ZSH_THEME_PWD_PROMPT="%10~"
  ZSH_THEME_PWD_PROMPT_SUFFIX=""

  ZSH_THEME_RETURN_PROMPT_SUCCESS_PREFIX=""
  ZSH_THEME_RETURN_PROMPT_SUCCESS="⏎"
  ZSH_THEME_RETURN_PROMPT_SUCCESS_SUFFIX=""

  ZSH_THEME_RETURN_PROMPT_ERROR_PREFIX=""
  ZSH_THEME_RETURN_PROMPT_ERROR="✘"
  ZSH_THEME_RETURN_PROMPT_ERROR_SUFFIX=""

  if command -v java >/dev/null 2>&1; then
    ZSH_THEME_JAVA_PROMPT_PREFIX=" [$(java_prompt_prefix):"
    ZSH_THEME_JAVA_PROMPT_SUFFIX="]"
  else
    ZSH_THEME_JAVA_PROMPT_PREFIX=" "
    ZSH_THEME_JAVA_PROMPT_SUFFIX=""
  fi

  if command -v go >/dev/null 2>&1; then
    ZSH_THEME_GO_PROMPT_PREFIX=" [$GO_PROMPT_PREFIX:"
    ZSH_THEME_GO_PROMPT_SUFFIX="]"
  else
    ZSH_THEME_GO_PROMPT_PREFIX=" "
    ZSH_THEME_GO_PROMPT_SUFFIX=""
  fi

  if command -v node >/dev/null 2>&1; then
    ZSH_THEME_NODE_PROMPT_PREFIX=" [$NODE_PROMPT_PREFIX:"
    ZSH_THEME_NODE_PROMPT_SUFFIX="]"
  else
    ZSH_THEME_NODE_PROMPT_PREFIX=" "
    ZSH_THEME_NODE_PROMPT_SUFFIX=""
  fi

  if command -v python3 >/dev/null 2>&1; then
    ZSH_THEME_PYTHON_PROMPT_PREFIX=" [$PYTHON_PROMPT_PREFIX:"
    ZSH_THEME_PYTHON_PROMPT_SUFFIX="]"
  elif command -v python >/dev/null 2>&1; then
    ZSH_THEME_PYTHON_PROMPT_PREFIX=" [$PYTHON_PROMPT_PREFIX:"
    ZSH_THEME_PYTHON_PROMPT_SUFFIX="]"
  else
    ZSH_THEME_PYTHON_PROMPT_PREFIX=" "
    ZSH_THEME_PYTHON_PROMPT_SUFFIX=""
  fi

  if command -v ruby >/dev/null 2>&1; then
    ZSH_THEME_RUBY_PROMPT_PREFIX=" [$RUBY_PROMPT_PREFIX:"
    ZSH_THEME_RUBY_PROMPT_SUFFIX="]"
  else
    ZSH_THEME_RUBY_PROMPT_PREFIX=" "
    ZSH_THEME_RUBY_PROMPT_SUFFIX=""
  fi

  if command -v scala >/dev/null 2>&1; then
    ZSH_THEME_SCALA_PROMPT_PREFIX=" [$SCALA_PROMPT_PREFIX:"
    ZSH_THEME_SCALA_PROMPT_SUFFIX="]"
  else
    ZSH_THEME_SCALA_PROMPT_PREFIX=" "
    ZSH_THEME_SCALA_PROMPT_SUFFIX=""
  fi

  ZSH_THEME_USER_PROMPT_SUPER_PREFIX=" "
  ZSH_THEME_USER_PROMPT_SUPER="⚡ λ"
  ZSH_THEME_USER_PROMPT_SUPER_SUFFIX=" "

  ZSH_THEME_USER_PROMPT_NONSUPER_PREFIX=" "
  ZSH_THEME_USER_PROMPT_NONSUPER="λ"
  ZSH_THEME_USER_PROMPT_NONSUPER_SUFFIX=" "

  ZSH_THEME_TIME_PROMPT_PREFIX=" "
  ZSH_THEME_TIME_PROMPT_SUFFIX=""

  ZSH_THEME_TIME_PERIOD_PROMPT_PREFIX=" "
  ZSH_THEME_TIME_PERIOD_PROMPT_SUFFIX=""

  SVN_SHOW_BRANCH="true"
  ZSH_PROMPT_BASE_COLOR=""
  ZSH_THEME_SVN_PROMPT_PREFIX=" $SVN_PROMPT_PREFIX:"
  ZSH_THEME_REPO_NAME_COLOR=""
  ZSH_THEME_SVN_PROMPT_DIRTY=" ✹"
  ZSH_THEME_SVN_PROMPT_CLEAN=""
  ZSH_THEME_SVN_PROMPT_DIRTY_PWD=" ✭"
  ZSH_THEME_SVN_PROMPT_CLEAN_PWD=""

  ZSH_THEME_GIT_PROMPT_PREFIX=" $GIT_PROMPT_PREFIX:"
  ZSH_THEME_GIT_PROMPT_SUFFIX=""
  ZSH_THEME_GIT_PROMPT_DIRTY=""
  ZSH_THEME_GIT_PROMPT_CLEAN=""

  ZSH_THEME_GIT_PROMPT_ADDED=" ✚"
  ZSH_THEME_GIT_PROMPT_MODIFIED=" ✹"
  ZSH_THEME_GIT_PROMPT_DELETED=" ✖"
  ZSH_THEME_GIT_PROMPT_RENAMED=" ➜"
  ZSH_THEME_GIT_PROMPT_UNMERGED=" ═"
  ZSH_THEME_GIT_PROMPT_UNTRACKED=" ✭"
fi