FROM ubuntu:jammy

HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD true
RUN useradd -m viewer
USER viewer
