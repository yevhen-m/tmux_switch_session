#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmux unbind-key s
tmux bind-key 'C-s' new-window "$CURRENT_DIR/scripts/switch_session.sh"
tmux bind-key 's' new-window "$CURRENT_DIR/scripts/switch_session.sh"
