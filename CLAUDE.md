# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal zsh configuration repository containing plugins and themes designed for use with Oh My Zsh or similar zsh frameworks. The plugins provide environment setup, aliases, and utility functions primarily for macOS development.

## Architecture

### Plugin Structure

Each plugin is a self-contained `.zsh` file in `plugins/<name>/<name>.zsh`. Plugins typically:
- Check for OS compatibility (usually Darwin/macOS)
- Check if required commands exist before configuring
- Export environment variables, define aliases, or provide utility functions

**Active Plugins:**
- `brew` - Homebrew setup and upgrade aliases (`brewup`, `brewupo`, `brewdeps`)
- `mise` - mise (runtime version manager) activation
- `path` - PATH manipulation utilities (`path-append`, `path-prepend`, `path-remove`, `path`)
- `java` - JDK version management (`jdk-set`, `jdk-list`, `jdk-check`, `jdk-reset`, `jdk-unset`)
- `terminal` - Terminal/iTerm configuration, tab management (`tab`, `tab-color`)
- `git` - Recursive git update utility (`git_up`)
- `compressed` - Archive extraction (`ex` function handles tar, zip, gz, bz2, 7z, etc.)
- `ps` - Process search (`any` function)
- `dict` - Dictionary lookup (`givedef`)
- `grep`, `curl`, `maven`, `gradle`, `sbt`, `editor`, `antigravity` - Environment configuration

**Deprecated Plugins** (`plugins/deprecated/`): Legacy configurations not actively maintained.

### Theme

`themes/jasonchaffee/jasonchaffee.zsh-theme` - Custom prompt showing:
- Programming language versions (Java, Scala, Go, Node, Python, Ruby) when installed
- Git/SVN branch and status
- Current directory, time, user privilege indicator

Use `prompt_set 1|2|3|4` to switch between prompt layouts.

## Plugin Conventions

- Use `command -v <cmd> >/dev/null 2>&1` to check command availability
- Use `[[ $(uname) = 'Darwin' ]]` for macOS-specific code
- The `path` plugin functions (`path-prepend`, `path-remove`) are dependencies for other plugins like `java`
