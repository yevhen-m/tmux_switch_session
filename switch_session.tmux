#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmux unbind-key s
tmux bind-key 'C-s' display-popup -h 90% -w 90% -E "$CURRENT_DIR/scripts/switch_session.sh"
tmux bind-key 's' display-popup -h 90% -w 90% -E "$CURRENT_DIR/scripts/switch_session.sh"
