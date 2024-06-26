#!/usr/bin/env bash

set -e
prompt="> "
tmux='/usr/bin/env tmux'

declare -A log_levels=( ["DEBUG"]=0 ["INFO"]=1 ["WARNING"]=2 ["ERROR"]=3 )

# Don't forget to change this to DEBUG before changing anything here ;)
LOG_LEVEL="INFO"
LOG_FILE="/tmp/tmux_switch_session.log"

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Check if the log level is valid
    if [[ ! ${log_levels[$level]+_} ]]; then
        echo "Unknown log level: $level"
        exit 1
    fi

    # Compare the current log level with the threshold set
    if [[ ${log_levels[$level]} -ge ${log_levels[$LOG_LEVEL]} ]]; then
        echo "$timestamp [$level] $message" >> "$LOG_FILE"
    fi
}

fuzzy_switch() {
    # Either fuzzy select an active session, or create a new one if provided
    # input does not match any active session's name.
    fzf_out=$(\
        $tmux ls -F '#{session_name}' | \
        # Don't show the current session on the list
        rg -v `tmux display-message -p '#{session_name}'` | \
        fzf --height=100% --print-query --border none --margin 1% --no-info \
        --header '📺 Session:' --color=header:italic \
        --preview 'tmux capture-pane -e -p -t {}' --preview-window right:75%:nowrap \
        --prompt="$prompt" --query "$1" || true)

    log_message "DEBUG" "Fzf output is '$fzf_out'"

    line_count=$(echo "$fzf_out" | wc -l)
    log_message "DEBUG" "Fzf output line count is '$line_count'"

    session_name=$(echo "$fzf_out" | tail -n1)
    log_message "DEBUG" "Fzf output session name is '$session_name'"

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
            # That was a typo, try to choose once more; pass inputted string a
            # query.
            fuzzy_switch "$(echo "$fzf_out" | head -n 1)"
            return
        fi
    elif [ -z "$session_name" ]; then
        log_message "DEBUG" "Not switching, exiting"
        exit 0
    else
        log_message "DEBUG" "Switching to '$session_name'"
        $tmux switch-client -t "$session_name"

    fi
    # Refresh tmux statusline
    sleep 0.1 && $tmux refresh-client -S
}

log_message "DEBUG" "Calling fuzzy_switch..."
fuzzy_switch
