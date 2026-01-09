#!/usr/bin/env bash

tmux display-popup -E -w 80% -h 60% "bash -c '
commands=(
  \"go build\"
  \"npm run dev\"
  \"npm run build\"
  \"composer run dev\"
  \"php artisan serve\"
  \"air\"
  \"reflex\"
)

selected=\$(printf \"%s\n\" \"\${commands[@]}\" | fzf --prompt=\"Select command to run: \")

if [ -n \"\$selected\" ]; then
    dir=\$(tmux display -p -F \"#{pane_current_path}\")
    # Run the command directly without nested bash quoting hell
    tmux new-window -n \"\${selected%% *}\" -c \"\$dir\"
    tmux send-keys -t \"\${selected%% *}\" \"\$selected\" C-m
    tmux select-window -t \"\${selected%% *}\"
fi
'"

