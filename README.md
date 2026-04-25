<p align="center">
  <img src="docs/images/banner.svg" alt="atlassian-browser-mcp banner" width="900"/>
</p>

# atlassian-browser-mcp

[![License: GPL-3.0](https://img.shields.io/github/license/GeiserX/atlassian-browser-mcp?style=flat-square)](LICENSE)
[![Python 3.12+](https://img.shields.io/badge/python-3.12+-3572A5?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![GitHub stars](https://img.shields.io/github/stars/GeiserX/atlassian-browser-mcp?style=flat-square)](https://github.com/GeiserX/atlassian-browser-mcp/stargazers)
[![mcp-atlassian](https://img.shields.io/badge/wraps-mcp--atlassian%200.21.x-blue?style=flat-square)](https://github.com/sooperset/mcp-atlassian)
[![GeiserX/atlassian-browser-mcp MCP server](https://glama.ai/mcp/servers/GeiserX/atlassian-browser-mcp/badges/score.svg)](https://glama.ai/mcp/servers/GeiserX/atlassian-browser-mcp)

MCP server that wraps the upstream [mcp-atlassian](https://github.com/sooperset/mcp-atlassian) toolset with browser-cookie authentication. By default it reuses cookies from an existing Firefox profile, so you can sign in through your normal browser and avoid API tokens. A Playwright-based manual login mode is still available when explicitly enabled.

## How it works

1. Sign in to Jira and Confluence in Firefox using your normal SSO/MFA flow
2. On startup, the server loads matching Firefox cookies with `browser-cookie3`
3. All MCP tool calls use those cookies via a custom `requests.Session` subclass
4. If an API response looks like an SSO redirect, the session reloads Firefox cookies and retries once

The server monkey-patches `JiraClient` and `ConfluenceClient` constructors in `mcp-atlassian` to inject the browser-backed session, giving full parity with the upstream tool surface (72 tools + 1 `atlassian_login` helper = 73 total).

## Files

| File | Purpose |
|------|---------|
| `atlassian_browser_mcp_full.py` | Entrypoint. Patches upstream clients, registers `atlassian_login` tool, runs the MCP server |
| `atlassian_browser_auth.py` | Shared auth: `BrowserCookieSession`, cookie providers, SSO detection |
| `run-atlassian-browser-mcp.sh` | Launcher: creates venv, installs deps via `uv`, runs compatibility check, starts server |
| `pyproject.toml` | Dependency pins |

## Usage

First, open Firefox and sign in to Jira and Confluence. Then run:

```bash
export JIRA_URL="https://jira.example.com"
export CONFLUENCE_URL="https://confluence.example.com"
./run-atlassian-browser-mcp.sh
```

Or configure as an MCP server in your editor (Cursor, Claude Code, etc.) pointing to the launcher script.

This server exposes Atlassian actions as MCP tools, not MCP resources. If your client reports `resources/list failed` or `resources/templates/list failed`, call the Jira/Confluence tools directly instead of resource discovery.

Firefox profile discovery is automatic. If Firefox has multiple profiles and the wrong one is selected, point directly at the cookie database:

```bash
export FIREFOX_COOKIE_FILE="$HOME/Library/Application Support/Firefox/Profiles/xxxx.default-release/cookies.sqlite"
./run-atlassian-browser-mcp.sh
```

To use the previous Playwright/Chromium login flow instead:

```bash
export COOKIES_PROVIDER=playwright
./run-atlassian-browser-mcp.sh
```

### Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `JIRA_URL` | _(required)_ | Jira base URL (e.g. `https://jira.example.com`) |
| `CONFLUENCE_URL` | _(required)_ | Confluence base URL (e.g. `https://confluence.example.com`) |
| `ATLASSIAN_BROWSER_AUTH_ENABLED` | `true` | Enable browser auth (set `false` to fall back to token auth) |
| `COOKIES_PROVIDER` | `firefox` | Cookie provider. Use `firefox` for existing Firefox cookies or `playwright` for the legacy Chromium login flow |
| `FIREFOX_COOKIE_FILE` | _(auto)_ | Optional path to a Firefox `cookies.sqlite` file when automatic discovery picks the wrong profile |
| `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY`, `NO_PROXY` | _(none)_ | Standard proxy environment variables honored by the underlying `requests.Session`; lowercase variants are also supported |
| `ATLASSIAN_BROWSER_PROFILE_DIR` | `./.atlassian-browser-profile` | Playwright mode only: persistent Chromium profile directory |
| `ATLASSIAN_STORAGE_STATE` | `./.atlassian-browser-state.json` | Playwright mode only: storage-state file |
| `ATLASSIAN_LOGIN_TIMEOUT_SECONDS` | `300` | Playwright mode only: seconds to wait for manual login |
| `ATLASSIAN_USERNAME` | _(none)_ | Playwright mode only: prefill username on SSO page |
| `ATLASSIAN_SSO_MARKERS` | _(auto)_ | Comma-separated URL/text markers for SSO redirect detection. Defaults cover Okta, ADFS, Azure AD, PingOne, Google SAML |
| `TOOLSETS` | `all` | Which upstream toolsets to enable |

## Requirements

- Python 3.12+
- [uv](https://docs.astral.sh/uv/) (for dependency management)
- Firefox with an active Jira/Confluence session
- Chromium only when `COOKIES_PROVIDER=playwright` (installed automatically by Playwright)
- Network access to your Atlassian instance
