#!/bin/sh
set -euo pipefail

session=unyka

if tmux has-session -t $session 2>/dev/null; then
  echo "session $session already exists."
  exit 0
fi

echo "Launching micro-services.."
tmux new-session -d -s $session
tmux split-window -h -t $session:1
tmux split-window -h -t $session:1

tmux select-pane -t $session:1.1
tmux split-window -v -t $session:1.1
tmux split-window -v -t $session:1.1

tmux select-pane -t $session:1.4
tmux split-window -v -t $session:1.4
tmux split-window -v -t $session:1.4

tmux select-pane -t $session:1.7
tmux split-window -v -t $session:1.7
tmux split-window -v -t $session:1.7

tmux send-keys -t $session:1.1 'cd ~/repo/unyka/auction' C-m
tmux send-keys -t $session:1.1 'skaffold dev' C-m
tmux send-keys -t $session:1.2 'cd ~/repo/unyka/bff' C-m
tmux send-keys -t $session:1.2 'skaffold dev' C-m
tmux send-keys -t $session:1.3 'cd ~/repo/unyka/bid' C-m
tmux send-keys -t $session:1.3 'skaffold dev' C-m
tmux send-keys -t $session:1.4 'cd ~/repo/unyka/bo' C-m
tmux send-keys -t $session:1.4 'skaffold dev' C-m
tmux send-keys -t $session:1.5 'cd ~/repo/unyka/identity' C-m
tmux send-keys -t $session:1.5 'skaffold dev' C-m
tmux send-keys -t $session:1.6 'cd ~/repo/unyka/media' C-m
tmux send-keys -t $session:1.6 'skaffold dev' C-m
tmux send-keys -t $session:1.7 'cd ~/repo/unyka/money' C-m
tmux send-keys -t $session:1.7 'skaffold dev' C-m
tmux send-keys -t $session:1.8 'cd ~/repo/unyka/notification' C-m
tmux send-keys -t $session:1.8 'skaffold dev' C-m
tmux send-keys -t $session:1.9 'cd ~/repo/unyka/profile' C-m
tmux send-keys -t $session:1.9 'skaffold dev' C-m
sleep 0.5

echo "Launching web apps.."
tmux new-window -t $session:2
tmux split-window -h -t $session:2
tmux send-keys -t $session:2.1 'cd ~/repo/unyka/webui-bo && docker compose up' C-m
tmux send-keys -t $session:2.2 'cd ~/repo/unyka/webui-client' C-m
tmux send-keys -t $session:2.2 'docker compose up' C-m
sleep 0.5

echo "Initializing dev env.."
tmux new-window -t $session:3
tmux send-keys -t $session:3.1 'k9s' C-m
sleep 0.5

tmux new-window -t $session:4
tmux send-keys -t $session:4.1 'cd ~/repo/unyka' C-m
tmux send-keys -t $session:4.1 'v' C-m
tmux send-keys -t $session:4.1 Space 'e'
echo "Welcome back Sir"
