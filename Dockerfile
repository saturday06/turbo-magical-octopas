FROM docker.all-hands.dev/all-hands-ai/runtime:0.34-nikolaik

HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD true
RUN useradd -m viewer
USER viewer
