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

The server monkey-patches `JiraClient` and `ConfluenceClient` constructors in `mcp-atlassian` to inject the browser-backed session, giving full parity with the upstream tool surface (73 Atlassian tools + 1 `atlassian_login` helper = 74 total).

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

### Tool Reference

Tool names below are the exposed MCP names in Codex. The wrapper prefixes Jira tools with `jira_` and Confluence tools with `confluence_`.

<details>
<summary>Jira tools</summary>

| Tool | Used for |
|------|----------|
| `jira_get_user_profile` | Retrieve profile information for a specific Jira user. |
| `jira_get_issue_watchers` | Get the list of watchers for a Jira issue. |
| `jira_add_watcher` | Add a user as a watcher to a Jira issue. |
| `jira_remove_watcher` | Remove a user from watching a Jira issue. |
| `jira_get_issue` | Get details of a specific Jira issue including its Epic links and relationship information. |
| `jira_search` | Search Jira issues using JQL (Jira Query Language). |
| `jira_search_fields` | Search Jira fields by keyword with fuzzy match. |
| `jira_get_field_options` | Get allowed option values for a custom field. |
| `jira_get_project_issues` | Get all issues for a specific Jira project. |
| `jira_get_transitions` | Get available status transitions for a Jira issue. |
| `jira_get_worklog` | Get worklog entries for a Jira issue. |
| `jira_download_attachments` | Download attachments from a Jira issue. |
| `jira_get_issue_images` | Get all images attached to a Jira issue as inline image content. |
| `jira_get_agile_boards` | Get Jira agile boards by name, project key, or type. |
| `jira_get_board_issues` | Get all issues linked to a specific board filtered by JQL. |
| `jira_get_sprints_from_board` | Get Jira sprints from board by state. |
| `jira_get_sprint_issues` | Get Jira issues from sprint. |
| `jira_get_link_types` | Get all available issue link types. |
| `jira_create_issue` | Create a new Jira issue with optional Epic link or parent for subtasks. |
| `jira_batch_create_issues` | Create multiple Jira issues in a batch. |
| `jira_batch_get_changelogs` | Get changelogs for multiple Jira issues (Cloud only). |
| `jira_update_issue` | Update an existing Jira issue including changing status, adding Epic links, updating fields, etc. |
| `jira_delete_issue` | Delete an existing Jira issue. |
| `jira_add_comment` | Add a comment to a Jira issue. |
| `jira_edit_comment` | Edit an existing comment on a Jira issue. |
| `jira_add_worklog` | Add a worklog entry to a Jira issue. |
| `jira_link_to_epic` | Link an existing issue to an epic. |
| `jira_create_issue_link` | Create a link between two Jira issues. |
| `jira_create_remote_issue_link` | Create a remote issue link (web link or Confluence link) for a Jira issue. |
| `jira_remove_issue_link` | Remove a link between two Jira issues. |
| `jira_transition_issue` | Transition a Jira issue to a new status. |
| `jira_create_sprint` | Create Jira sprint for a board. |
| `jira_update_sprint` | Update Jira sprint. |
| `jira_add_issues_to_sprint` | Add issues to a Jira sprint. |
| `jira_get_project_versions` | Get all fix versions for a specific Jira project. |
| `jira_get_project_components` | Get all components for a specific Jira project. |
| `jira_get_all_projects` | Get all Jira projects accessible to the current user. |
| `jira_get_service_desk_for_project` | Get the Jira Service Desk associated with a project key. |
| `jira_get_service_desk_queues` | Get queues for a Jira Service Desk. |
| `jira_get_queue_issues` | Get issues from a Jira Service Desk queue. |
| `jira_create_version` | Create a new fix version in a Jira project. |
| `jira_batch_create_versions` | Batch create multiple versions in a Jira project. |
| `jira_get_issue_proforma_forms` | Get all ProForma forms associated with a Jira issue. |
| `jira_get_proforma_form_details` | Get detailed information about a specific ProForma form. |
| `jira_update_proforma_form_answers` | Update form field answers using the Jira Forms REST API. |
| `jira_get_issue_dates` | Get date information and status transition history for a Jira issue. |
| `jira_get_issue_sla` | Calculate SLA metrics for a Jira issue. |
| `jira_get_issue_development_info` | Get development information (PRs, commits, branches) linked to a Jira issue. |
| `jira_get_issues_development_info` | Get development information for multiple Jira issues. |

</details>

<details>
<summary>Confluence tools</summary>

| Tool | Used for |
|------|----------|
| `confluence_search` | Search Confluence content using simple terms or CQL. |
| `confluence_get_page` | Get content of a specific Confluence page by its ID, or by its title and space key. |
| `confluence_get_page_children` | Get child pages and folders of a specific Confluence page. |
| `confluence_get_space_page_tree` | Get page hierarchy for a Confluence space as a flat list. |
| `confluence_get_comments` | Get comments for a specific Confluence page. |
| `confluence_get_labels` | Get labels for Confluence content (pages, blog posts, or attachments). |
| `confluence_add_label` | Add label to Confluence content (pages, blog posts, or attachments). |
| `confluence_create_page` | Create a new Confluence page. |
| `confluence_update_page` | Update an existing Confluence page. |
| `confluence_delete_page` | Delete an existing Confluence page. |
| `confluence_move_page` | Move a Confluence page to a new parent or space. |
| `confluence_add_comment` | Add a comment to a Confluence page. |
| `confluence_reply_to_comment` | Reply to an existing comment thread on a Confluence page. |
| `confluence_search_user` | Search Confluence users using CQL (Cloud) or group member API (Server/DC). |
| `confluence_get_page_history` | Get a historical version of a specific Confluence page. |
| `confluence_get_page_diff` | Get a unified diff between two versions of a Confluence page. |
| `confluence_get_page_views` | Get view statistics for a Confluence page. |
| `confluence_upload_attachment` | Upload an attachment to Confluence content (page or blog post). |
| `confluence_upload_attachments` | Upload multiple attachments to Confluence content in a single operation. |
| `confluence_get_attachments` | List all attachments for a Confluence content item (page or blog post). |
| `confluence_download_attachment` | Download an attachment from Confluence as an embedded resource. |
| `confluence_download_content_attachments` | Download all attachments for a Confluence content item as embedded resources. |
| `confluence_delete_attachment` | Permanently delete an attachment from Confluence. |
| `confluence_get_page_images` | Get all images attached to a Confluence page as inline image content. |

</details>

<details>
<summary>Helper</summary>

| Tool | Used for |
|------|----------|
| `atlassian_login` | Refresh browser-backed Atlassian authentication. |

</details>

### Minimize Codex token usage

If you use this server from Codex, reduce token usage by redacting the MCP tool list in Codex itself. Codex supports per-server tool allowlists and denylists in `~/.codex/config.toml` via `enabled_tools` and `disabled_tools`; see the official [Codex MCP docs](https://developers.openai.com/codex/mcp) and [config reference](https://developers.openai.com/codex/config-reference).

For the lowest token usage, prefer `enabled_tools`. That prevents all non-listed tool schemas from being exposed to Codex for this MCP server.

Example: keep only basic Jira lookup tools available in Codex:

```toml
[mcp_servers.atlassian_browser]
command = "/Users/you/Projects/atlassian-browser-mcp/run-atlassian-browser-mcp.sh"
cwd = "/Users/you/Projects/atlassian-browser-mcp"
startup_timeout_sec = 30
tool_timeout_sec = 120
enabled_tools = [
  "jira_search",
  "jira_get_issue",
  "jira_download_attachments", 
  "jira_get_issue_images"
]

[mcp_servers.atlassian_browser.env]
JIRA_URL = "https://jira.example.com"
CONFLUENCE_URL = "https://confluence.example.com"
```

If you want to block only a few tools and keep the rest, use `disabled_tools` instead:

```toml
[mcp_servers.atlassian_browser]
command = "/Users/you/Projects/atlassian-browser-mcp/run-atlassian-browser-mcp.sh"
cwd = "/Users/you/Projects/atlassian-browser-mcp"
disabled_tools = [
  "confluence_search",
  "confluence_get_page",
]
```

Notes:

- `enabled_tools` is better than `disabled_tools` when your goal is token reduction.
- Redaction is client-side in Codex. Other MCP clients still see the full tool surface unless they apply their own filtering.
- Restart Codex after changing `~/.codex/config.toml`.
- Add `atlassian_login` to `enabled_tools` only if you need the manual login helper exposed.

### Use a Jira summarizer subagent in Codex

For even lower main-session token usage, keep Atlassian MCP tools out of the main Codex session and expose them only to a focused Jira summarizer subagent. Codex custom agents can live in `~/.codex/agents/` for personal use or `.codex/agents/` for project-scoped use. Codex only spawns subagents when you explicitly ask it to.

Use `gpt-5.4-mini` with `model_reasoning_effort = "medium"` by default. Jira summarization is mostly retrieval, filtering, and compression. Use `gpt-5.4` with `model_reasoning_effort = "high"` only when the Jira work is complex, spans multiple tickets, or needs careful risk synthesis. See the official [Codex subagents docs](https://developers.openai.com/codex/subagents), [Codex MCP docs](https://developers.openai.com/codex/mcp), [Codex config reference](https://developers.openai.com/codex/config-reference), and [model list](https://developers.openai.com/api/docs/models).

Create `~/.codex/agents/jira-summarizer.toml`:

```toml
name = "jira_summarizer"
description = "Reads Jira issues through atlassian-browser-mcp and returns compact summaries for the parent agent."
model = "gpt-5.4-mini"
model_reasoning_effort = "medium"
sandbox_mode = "read-only"

developer_instructions = """
Use Jira tools only to gather issue context.
Summarize for the parent agent, not for an end user.
When reading a specific issue, include comments because they often contain decisions, clarifications, and current blockers.
Check for attachments and download them when filenames, metadata, or the parent request suggest they may contain useful requirements, screenshots, logs, or reproduction details.
Prefer compact output: status, assignee, priority, key dates, requirements, blockers, comments, attachment findings, and engineering implications.
Do not make code changes.
Do not fetch unrelated issues unless the parent agent asks for linked or related work.
"""

[mcp_servers.atlassian_browser]
command = "/Users/you/Projects/atlassian-browser-mcp/run-atlassian-browser-mcp.sh"
cwd = "/Users/you/Projects/atlassian-browser-mcp"
startup_timeout_sec = 30
tool_timeout_sec = 120
enabled_tools = [
  "jira_search",
  "jira_get_issue",
  "jira_download_attachments",
  "jira_get_issue_images",
]

[mcp_servers.atlassian_browser.env]
JIRA_URL = "https://jira.example.com"
CONFLUENCE_URL = "https://confluence.example.com"
```

Then ask the main agent to delegate Jira reading:

```text
Use jira_summarizer to read BIZ-20528, include comments, attachments, status, assignee, and acceptance details if available, and return a compact summary with blockers and engineering implications.
```

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
