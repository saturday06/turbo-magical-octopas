#!/bin/bash

set -eux -o pipefail

export DISPLAY=:0

(
  set +e
  (while true; do Xvfb :0 -screen 0 1600x900x24 -fbdir "$(mktemp -d)"; done) 2>&1 | tee var/log/Xvfb.log
) &
timeout 5 sh -c "until glxinfo > /dev/null; do sleep 0.1; done"

fvwm >var/log/fvwm.log 2>&1 &

(
  set +e
  (while true; do x11vnc -display "$DISPLAY" -forever; done) 2>&1 | tee var/log/x11vnc.log
) &
timeout 5 sh -c "until nc -z 127.0.0.1 5900; do sleep 0.1; done"

lxterminal >var/log/lxterminal.log 2>&1 &

(
  set +e
  (while true; do "$HOME/noVNC/utils/novnc_proxy" --listen 6080 --vnc 127.0.0.1:5900; done) 2>&1 | tee var/log/noVNC.log
) &
timeout 5 sh -c "until nc -z 127.0.0.1 6080; do sleep 0.1; done"
timeout 5 sh -c "until curl --fail http://127.0.0.1:6080; do sleep 0.1; done"
