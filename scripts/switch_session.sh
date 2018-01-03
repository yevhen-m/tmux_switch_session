#/usr/bin/env bash

set -e
prompt=">>> "
tmux='/usr/bin/env tmux'

fuzzy_switch() {
    # Either fuzzy select an active session, or create a new one if provided
    # input does not match any active session's name.
    fzf_out=$(\
        $tmux ls -F '#{session_name}' | \
        grep -v '^1' | sort -r | \
        perl -pe 's/^0 [0-9]+//' | \
        fzf --height=100% --print-query --prompt="$prompt" || \
        true\
        )
    line_count=$(echo "$fzf_out" | wc -l)
    session_name=$(echo "$fzf_out" | tail -n1)

    if [ $line_count -eq 1 ] && [ -n "$session_name" ]; then
        # Session name did not match, create a new one;
        # want to ensure that was not a typo.
        read -p "Create \"$session_name\"? " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            unset TMUX
            $tmux new-session -d -s "$session_name"
            $tmux switch-client -t "$session_name"
        else
            # That was a typo, try to choose once more
            fuzzy_switch
            return
        fi
    else
        $tmux switch-client -t "$session_name"

    fi
    # Refresh tmux statusline
    sleep 0.1 && $tmux refresh-client -S
}

fuzzy_switch
