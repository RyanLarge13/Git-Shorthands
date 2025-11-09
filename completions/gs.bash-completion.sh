# bash completion for gs
_gs_completions() {
    local cur prev

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # First value suggestions
    if [[ $COMP_CWORD == 1 ]]; then
        COMPREPLY=( $( compgen -W "clone init commit pull merge config conf help -h -H -p -m -s -v version" -- "$cur" ) )
        return 0
    fi

    # Add dynamic suggestions if you want:
    if [[ $prev = "clone" ]]; then
        COMPREPLY=( $( compgen -W "$(ls)" -- "$cur" ) )
    fi
}

complete -F _gs_completions gs