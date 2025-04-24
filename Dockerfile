FROM ubuntu:jammy

RUN bash <<'INSTALL_PACKAGES'
  set -eu -o pipefail
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install \
    "blender=*" \
    "curl=*" \
    "dbus=*" \
    "lxterminal=*" \
    "fvwm=*" \
    "less=*" \
    "mesa-utils=*" \
    "netcat-openbsd=*" \
    "openjdk-17-jre=*" \
    "procps=*" \
    "python3-numpy=*" \
    "recordmydesktop=*" \
    "x11-xserver-utils=*" \
    "x11vnc=*" \
    "xvfb=*" \
    "xz-utils=*" \
    --yes --no-install-recommends
  apt-get clean
  rm -rf /var/lib/apt/lists/
INSTALL_PACKAGES

RUN bash <<'INSTALL_NOVNC'
  set -eu -o pipefail

  cd ~

  mkdir noVNC
  curl -LSf --retry 5 https://github.com/novnc/noVNC/archive/cdfb33665195eb9a73fb00feb6ebaccd1068cd50.tar.gz | tar -C noVNC --strip-component=1 -zxf -

  # https://github.com/novnc/noVNC/blob/cdfb33665195eb9a73fb00feb6ebaccd1068cd50/utils/novnc_proxy#L165
  mkdir noVNC/utils/websockify
  curl -LSf --retry 5 https://github.com/novnc/websockify/archive/33910d758d2c495dd1d380729c31bacbf8229ed0.tar.gz | tar -C noVNC/utils/websockify --strip-component=1 -zxf -
INSTALL_NOVNC

RUN bash <<'START_NOVNC'
  set -eu -o pipefail
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
START_NOVNC

HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD true
RUN useradd -m viewer
USER viewer
