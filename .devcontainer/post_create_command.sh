#!/usr/bin/env bash
set -euo pipefail

pipx install uv || true
corepack enable
make dev-setup

cat <<'EOF' >> ~/.bashrc
alias start-api='cd /workspaces/dev-template/api && uv run uvicorn app.main:app --host 0.0.0.0 --port 5001 --reload'
alias start-web='cd /workspaces/dev-template/web && pnpm dev'
alias start-stack='cd /workspaces/dev-template && make dev'
EOF

