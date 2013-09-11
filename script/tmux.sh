tmux -2 new-session -d -s overmind

tmux new-window -t overmind:1 -n 'vim'
tmux send-keys 'vim' C-m

tmux new-window -t overmind:2

tmux new-window -t overmind:3 -n 'console'
tmux send-keys 'bundle exec rails c' C-m

tmux new-window -t overmind:4 -n 'foreman'
tmux send-keys 'bundle exec foreman start -f Procfile.dev' C-m

tmux select-window -t overmind:1

tmux -2 attach-session -t overmind
