#!/bin/sh
set -euo pipefail

mark_real_window() {
  tmux set-window-option -t "$1" @autocreated false
  tmux set-window-option -t "$1" @is_window_pristine false
}

session=unyka

if tmux has-session -t $session 2>/dev/null; then
  echo "session $session already exists."
  exit 0
fi

echo "Launching micro-services.."
tmux new-session -d -s $session
mark_real_window $session:1
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

echo "Launching web apps.."
tmux new-window -t $session:2
mark_real_window $session:2
tmux split-window -h -t $session:2
tmux send-keys -t $session:2.1 'cd ~/repo/unyka/webui-bo' C-m
tmux send-keys -t $session:2.1 'skaffold dev' C-m
tmux send-keys -t $session:2.2 'cd ~/repo/unyka/webui-client' C-m
tmux send-keys -t $session:2.2 'skaffold dev' C-m

echo "Launching port-forwarding.."
tmux new-window -t $session:10
mark_real_window $session:10
tmux split-window -h -t $session:10

tmux select-pane -t $session:10.2
tmux split-window -v -t $session:10.2
tmux split-window -v -t $session:10.2

tmux send-keys -t $session:10.1 'cd ~/repo/unyka/infra/terraform-kind' C-m
tmux send-keys -t $session:10.1 './dns.sh dev' C-m

tmux send-keys -t $session:10.2 'cd && kubectl -n unyka-mailhog port-forward svc/mailhog 8025' C-m
tmux send-keys -t $session:10.3 'cd && kubectl -n unyka-identity port-forward svc/keycloak 8080' C-m
tmux send-keys -t $session:10.4 'cd && kubectl -n unyka-s3 port-forward svc/rustfs-svc 9000' C-m

echo "Initializing dev env.."
tmux new-window -t $session:3
mark_real_window $session:3
tmux send-keys -t $session:3.1 'k9s' C-m

tmux new-window -t $session:4
mark_real_window $session:4
tmux send-keys -t $session:4.1 'cd ~/repo/unyka' C-m
tmux send-keys -t $session:4.1 'v' C-m
tmux send-keys -t $session:4.1 Space 'e'

tmux new-window -t $session:5
mark_real_window $session:5
tmux send-keys -t $session:5.1 'cd ~/repo/unyka' C-m
tmux send-keys -t $session:5.1 'gst' C-m

echo "Welcome back Sir"
