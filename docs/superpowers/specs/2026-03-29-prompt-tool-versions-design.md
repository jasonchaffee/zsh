# Prompt Tool Versions & Configuration System

**Date:** 2026-03-29
**Status:** Draft
**Scope:** Extend the jasonchaffee zsh theme with categorized tool version display and a runtime configuration system.

## Problem

The current prompt shows language runtime versions (Java, Go, Node, Python, Ruby, Scala) on a single line. As the development toolchain grows to include infrastructure-as-code, container orchestration, and AI CLI tools, the prompt needs a structured way to display and configure these additional version indicators.

## Design

### Category System

Tool versions are organized into four categories, each rendered on its own line. If no tools in a category are installed, that line is hidden entirely.

| Category | Label (text) | Label (emoji) | Tools (installed) | Stubs (ready when installed) |
|---|---|---|---|---|
| Languages | `lang:` | `📘` | jdk, scala, go, node, py, rb | — |
| IaC | `iac:` | `🏗` | tf, tg | pulumi, ansible, packer |
| Ops | `ops:` | `📦` | docker, helm, k8s, k9s | — |
| AI CLI | `ai:` | `🤖` | claude, codex, gemini, copilot, cursor | — |

### Prompt Layout

All four `prompt_one` through `prompt_four` functions are updated to include the new rows. Multi-line prompts (three/four) render as:

```
lang: [jdk:26] [go:1.26.1] [node:25.8.2] [py:3.14.3] [rb:2.6.10]
iac: [tf:1.14.8] [tg:0.99.5]
ops: [docker:27.5.1] [helm:3.17.1] [k8s:1.34.5] [k9s:0.50.18]
ai: [claude:2.1.86] [codex:0.117.0] [gemini:0.35.3] [copilot:0.0.422] [cursor:2.6.21]
⏎ ~ git:master λ
```

Empty categories produce no output (no empty label lines).

`prompt_one` renders all rows inline on a single line. `prompt_two` through `prompt_four` use separate lines per category.

### Known Risks

- **Slow commands:** Tools like `docker --version` can hang if the Docker daemon is unresponsive. No timeout mechanism is included in this iteration. If this becomes a problem, async version fetching or caching can be added later.

### New Version Functions

Each tool gets a `*_prompt_info()` function following the existing pattern:

| Function | Command | Version extraction |
|---|---|---|
| `terraform_prompt_info` | `terraform version` | first line, strip "Terraform v" |
| `terragrunt_prompt_info` | `terragrunt --version` | strip "terragrunt version v" |
| `docker_prompt_info` | `docker --version` | extract semver from "Docker version X," |
| `helm_prompt_info` | `helm version --short` | strip "v" prefix and "+build" suffix |
| `kubectl_prompt_info` | `kubectl version --client` | extract version from "Client Version: vX" |
| `k9s_prompt_info` | `k9s version --short` | extract version from "Version" line, strip "v" |
| `claude_prompt_info` | `claude --version` | first line, already clean |
| `codex_prompt_info` | `codex --version` | strip "codex-cli " prefix |
| `gemini_prompt_info` | `gemini --version` | already clean |
| `copilot_prompt_info` | `gh copilot --version` | strip "GitHub Copilot CLI " and trailing dot |
| `cursor_prompt_info` | `cursor --version` | first line only |
| `pulumi_prompt_info` | `pulumi version` | stub — returns empty if not installed |
| `ansible_prompt_info` | `ansible --version` | stub — first line, strip "ansible " prefix |
| `packer_prompt_info` | `packer version` | stub — first line, strip "Packer v" |

All functions are guarded with `command -v <cmd> >/dev/null 2>&1` — missing tools produce no output.

### Version Cleaning

A helper function `_clean_version()` handles common version string noise:

- Strip leading `v` or `V`
- Strip `+<build>` suffixes (e.g., `+g980d8ac`) — these are build metadata, not meaningful
- Strip known noise suffixes: `-rd`, `-dispatcher` — platform-specific build tags
- Preserve pre-release identifiers like `-rc1`, `-beta.2` — these are meaningful version info
- Strip trailing dots

Applied when `PROMPT_VERSION_MODE=clean` (default). When `raw`, the function passes through unmodified.

### Row Functions

Four row functions aggregate their category's tools:

```zsh
lang_row_info()  # collects: java, scala, go, node, python, ruby
iac_row_info()   # collects: terraform, terragrunt, pulumi, ansible, packer
ops_row_info()   # collects: docker, helm, kubectl, k9s
ai_row_info()    # collects: claude, codex, gemini, copilot, cursor
```

Each row function:
1. Collects output from all its tool functions into an array of `[label:version]` strings
2. If all are empty, returns nothing (no label, no line)
3. If `PROMPT_ORDER_MODE=alpha`, sorts the array alphabetically by tool label
4. If `PROMPT_ORDER_MODE=fixed` (default), preserves the hardcoded order
5. Prepends the category label (based on current label style) and returns the assembled line

**Fixed order (default):**

| Category | Order | Rationale |
|---|---|---|
| lang | jdk, scala, go, node, py, rb | JVM langs first, then by ecosystem |
| iac | tf, tg, pulumi, ansible, packer | terraform/terragrunt paired, then others |
| ops | docker, helm, k8s, k9s | build → deploy → manage → monitor |
| ai | claude, codex, gemini, copilot, cursor | by market prominence |

### Configuration System

Five configuration functions, all taking effect immediately:

#### `prompt_theme <name>`

Named presets that set all three colors at once:

| Preset | Label | Tool | Version |
|---|---|---|---|
| `default` | cyan | yellow | magenta |
| `ocean` | blue | cyan | green |
| `warm` | red | yellow | green |
| `mono` | white | white | white |
| `matrix` | green | green | cyan |

#### `prompt_colors [slot] <color>`

Granular color override. Two calling conventions:

- `prompt_colors <slot> <color>` — change one slot (2 args). Slots: `label`, `tool`, `version`
- `prompt_colors <label> <tool> <version>` — set all three positionally (3 args)

Any other argument count prints usage. Valid colors: red, green, yellow, blue, magenta, cyan, white.

#### `prompt_labels <style>`

Switch row label style:

- `text` (default) — `lang:`, `iac:`, `ops:`, `ai:`
- `emoji` — 📘, 🏗, 📦, 🤖
- `none` — no labels, just the bracket groups

#### `prompt_versions <mode>`

Toggle version string cleanup:

- `clean` (default) — normalized semver-like output
- `raw` — display tool output as-is

#### `prompt_order <mode>`

Toggle tool ordering within each category row:

- `fixed` (default) — hardcoded logical order (see table above)
- `alpha` — alphabetical by tool label

### Configuration Variables

All configuration state is stored in shell variables:

```zsh
PROMPT_LABEL_COLOR=cyan      # category label color
PROMPT_TOOL_COLOR=yellow     # tool name color
PROMPT_VERSION_COLOR=magenta # version number color
PROMPT_LABEL_STYLE=text      # text|emoji|none
PROMPT_VERSION_MODE=clean    # clean|raw
PROMPT_ORDER_MODE=fixed      # fixed|alpha
```

Users can set these directly in `.zshrc` or use the functions interactively.

### PREFIX/SUFFIX Migration

The existing language functions use `ZSH_THEME_*_PROMPT_PREFIX/SUFFIX` variables that bake colors in at load time. To support runtime color changes, these are refactored:

- PREFIX/SUFFIX values are computed from `PROMPT_TOOL_COLOR` and `PROMPT_VERSION_COLOR` via a `_update_theme_colors()` helper
- `_update_theme_colors()` is called at theme load time and whenever `prompt_theme` or `prompt_colors` is invoked
- Existing language functions (`java_prompt_info`, `go_prompt_info`, etc.) continue using PREFIX/SUFFIX — no API change, just the values become dynamic

### Implementation Structure

All code lives in the existing file `themes/jasonchaffee/jasonchaffee.zsh-theme`. No new files.

Code organization within the file:

1. Configuration variable defaults
2. `_clean_version` helper
3. `_update_theme_colors` helper (sets all PREFIX/SUFFIX vars from config vars)
4. Existing language functions (unchanged API, colors now dynamic)
5. New tool version functions (terraform, terragrunt, docker, helm, kubectl, k9s, claude, codex, gemini, copilot, cursor, pulumi, ansible, packer)
6. Row functions (lang, iac, ops, ai)
7. Configuration functions (prompt_theme, prompt_colors, prompt_labels, prompt_versions)
8. Updated prompt functions (prompt_one through prompt_four)
9. Initial call to `_update_theme_colors` with defaults

### Dumb Terminal Support

The existing `if [[ "$TERM" != "dumb" ]]` branch is preserved. The dumb terminal branch gets the same new functions and rows but without color codes, matching the existing pattern.

## Testing Strategy

1. **Version function tests** — source the theme, verify each function returns expected format for installed tools and empty string for missing tools
2. **Clean version tests** — verify `_clean_version` strips prefixes/suffixes correctly across edge cases: `v1.2.3`, `1.2.3+build`, `0.0.422.`, `v1.2.3-rc1`
3. **Row visibility tests** — verify row functions return empty when no tools in the category are available
4. **Config function tests** — verify `prompt_theme`, `prompt_colors`, `prompt_labels`, `prompt_versions` update variables correctly
5. **Prompt integration tests** — verify `prompt_set 1|2|3|4` includes new rows

## README Update

Update the existing README to document:
- New tool categories and which tools are displayed
- Configuration functions (`prompt_theme`, `prompt_colors`, `prompt_labels`, `prompt_versions`)
- Available presets
- Examples of customization

## Out of Scope

- Performance optimization (caching version lookups) — can be added later if prompt becomes slow
- Per-directory tool filtering — all installed tools always show
- Custom category creation — categories are hardcoded
