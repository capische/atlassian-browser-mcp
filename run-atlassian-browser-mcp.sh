#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${ROOT_DIR}/.venv-atlassian-browser"
PYTHON_BIN="${VENV_DIR}/bin/python"
MCP_BIN="${VENV_DIR}/bin/atlassian-browser-mcp"
COOKIES_PROVIDER_RAW="${COOKIES_PROVIDER:-firefox}"
COOKIES_PROVIDER_NORMALIZED="$(printf '%s' "${COOKIES_PROVIDER_RAW}" | tr '[:upper:]' '[:lower:]')"
INSTALL_TARGET="${ROOT_DIR}"
UV_BIN="$(command -v uv || true)"

if [[ -z "${UV_BIN}" && -x /opt/homebrew/bin/uv ]]; then
  UV_BIN="/opt/homebrew/bin/uv"
fi

if [[ "${COOKIES_PROVIDER_NORMALIZED}" == "playwright" ]]; then
  INSTALL_TARGET="${ROOT_DIR}[playwright]"
fi

if [[ -z "${UV_BIN}" ]]; then
  echo "uv is required but not installed." >&2
  exit 1
fi

if [[ ! -x "${PYTHON_BIN}" ]]; then
  "${UV_BIN}" venv "${VENV_DIR}"
fi

if ! "${PYTHON_BIN}" - <<'PY' >/dev/null 2>&1
from importlib.metadata import version
import os
assert version("atlassian-browser-mcp") == "1.0.0"
import browser_cookie3
import mcp_atlassian
import requests
import socksio
if os.environ.get("COOKIES_PROVIDER", "firefox").strip().lower() == "playwright":
    import playwright
PY
then
  "${UV_BIN}" pip install --python "${PYTHON_BIN}" -e "${INSTALL_TARGET}"
fi

if [[ "${COOKIES_PROVIDER_NORMALIZED}" == "playwright" ]]; then
  "${PYTHON_BIN}" -m playwright install chromium >/dev/null
fi

# Startup compatibility assertion: verify the upstream version and patched signatures
"${PYTHON_BIN}" - <<'PY'
from atlassian_browser_mcp_full import assert_upstream_compatibility
assert_upstream_compatibility()
PY

exec "${MCP_BIN}"
