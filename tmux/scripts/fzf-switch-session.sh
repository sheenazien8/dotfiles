#!/usr/bin/env bash

# Detect popup support
if tmux display-popup -E true &>/dev/null; then
  # tmux >= 3.2 supports popups
  tmux display-popup -E -w 80% -h 60% "
    selected=\$(tmux list-windows -a -F '#{session_name}:#{window_index} #{window_name}' \
      | fzf --reverse --prompt='Switch window > ' \
        --preview 'tmux capture-pane -pt {1} -S -20 | tail -n 20 | bat --style=plain --color=always' \
        --preview-window=right:65%:wrap:border-left)

    if [ -n \"\$selected\" ]; then
      target=\$(echo \"\$selected\" | awk '{print \$1}')
      tmux switch-client -t \"\$target\"
    fi
  "
else
  # fallback for tmux < 3.2 using split
  tmux split-window -p 40 -v "bash -c '
  selected=\$(tmux list-windows -a -F \"#{session_name}:#{window_index} #{window_name}\" \
    | fzf --reverse --prompt=\"Switch window > \" \
      --preview \"tmux capture-pane -pt {1} -S -20 | tail -n 20 | bat --style=plain --color=always\" \
      --preview-window=right:65%:wrap:border-left)
  if [ -n \"\$selected\" ]; then
    target=\$(echo \"\$selected\" | awk '{print \$1}')
    tmux switch-client -t \"\$target\"
  fi
  '"
fi

