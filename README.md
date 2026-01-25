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

`jasonchaffee` - Custom prompt showing:
- Programming language versions (Java, Scala, Go, Node, Python, Ruby)
- Git/SVN branch and status
- Current directory, time, user privilege indicator

Use `prompt_set 1|2|3|4` to switch between prompt layouts.
