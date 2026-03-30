# zsh

Personal zsh plugins and themes for macOS development.

## Usage

Add plugins to your `.zsh_plugins.txt` (for Antidote) or source directly:

```zsh
# With Antidote
jasonchaffee/zsh path:plugins/brew
jasonchaffee/zsh path:plugins/mise
jasonchaffee/zsh path:plugins/path
# ... etc

# Theme
jasonchaffee/zsh path:themes/jasonchaffee
```

## Plugins

| Plugin | Description |
|--------|-------------|
| `brew` | Homebrew setup and upgrade aliases (`brewup`, `brewupo`, `brewdeps`) |
| `mise` | mise runtime version manager activation |
| `path` | PATH utilities (`path-append`, `path-prepend`, `path-remove`, `path`) |
| `java` | JDK version management (`jdk-set`, `jdk-list`, `jdk-check`, `jdk-reset`) |
| `terminal` | Terminal/iTerm tab management (`tab`, `tab-color`) |
| `git` | Recursive git update (`git_up`) |
| `compressed` | Archive extraction (`ex` - handles tar, zip, gz, bz2, 7z, etc.) |
| `ps` | Process search (`any`) |
| `dict` | Dictionary lookup (`givedef`) |
| `grep` | Grep environment configuration |
| `curl` | Curl environment configuration |
| `maven` | Maven environment configuration |
| `gradle` | Gradle environment configuration |
| `sbt` | SBT environment configuration |
| `editor` | Editor environment configuration |
| `antigravity` | Miscellaneous utilities |

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
