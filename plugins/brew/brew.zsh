if [[ $(uname) = 'Darwin' ]]; then
    if command -v brew >/dev/null 2>&1; then

        # Prefer brew install binaries over system binaries
        export PATH="/opt/homebrew/bin:$PATH"
        
        # refresh brew by upgrading all outdated casks
        alias brewupo='brew outdated | while read cask; do brew upgrade $cask; done'
        alias brewup='brew update && brew upgrade && brew cleanup'
        
        function brewdeps() {
            brew list | while read cask; do echo -n $fg[blue] $cask $fg[white]; brew deps $cask | awk '{printf(" %s ", $0)}'; echo ""; done
        }
    fi
fi