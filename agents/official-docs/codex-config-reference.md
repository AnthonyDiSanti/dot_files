# Configuration Reference

Use this page as a searchable reference for Codex configuration files. For conceptual guidance and examples, start with [Config basics](https://developers.openai.com/codex/config-basic) and [Advanced Config](https://developers.openai.com/codex/config-advanced).

## `config.toml`

User-level configuration lives in `~/.codex/config.toml`. You can also add project-scoped overrides in `.codex/config.toml` files. Codex loads project-scoped config files only when you trust the project.

For sandbox and approval keys (`approval_policy`, `sandbox_mode`, and `sandbox_workspace_write.*`), pair this reference with [Sandbox and approvals](https://developers.openai.com/codex/agent-approvals-security#sandbox-and-approvals), [Protected paths in writable roots](https://developers.openai.com/codex/agent-approvals-security#protected-paths-in-writable-roots), and [Network access](https://developers.openai.com/codex/agent-approvals-security#network-access).

<ConfigTable
  options={[
    {
      key: "model",
      type: "string",
      description: "Model to use (e.g., `gpt-5.5`).",
    },
    {
      key: "review_model",
      type: "string",
      description:
        "Optional model override used by `/review` (defaults to the current session model).",
    },
    {
      key: "model_provider",
      type: "string",
      description: "Provider id from `model_providers` (default: `openai`).",
    },
    {
      key: "openai_base_url",
      type: "string",
      description:
        "Base URL override for the built-in `openai` model provider.",
    },
    {
      key: "model_context_window",
      type: "number",
      description: "Context window tokens available to the active model.",
    },
    {
      key: "model_auto_compact_token_limit",
      type: "number",
      description:
        "Token threshold that triggers automatic history compaction (unset uses model defaults).",
    },
    {
      key: "model_catalog_json",
      type: "string (path)",
      description:
        "Optional path to a JSON model catalog loaded on startup. Profile-level `profiles.<name>.model_catalog_json` can override this per profile.",
    },
    {
      key: "oss_provider",
      type: "lmstudio | ollama",
      description:
        "Default local provider used when running with `--oss` (defaults to prompting if unset).",
    },
    {
      key: "approval_policy",
      type: "untrusted | on-request | never | { granular = { sandbox_approval = bool, rules = bool, mcp_elicitations = bool, request_permissions = bool, skill_approval = bool } }",
      description:
        "Controls when Codex pauses for approval before executing commands. You can also use `approval_policy = { granular = { ... } }` to allow or auto-reject specific prompt categories while keeping other prompts interactive. `on-failure` is deprecated; use `on-request` for interactive runs or `never` for non-interactive runs.",
    },
    {
      key: "approval_policy.granular.sandbox_approval",
      type: "boolean",
      description:
        "When `true`, sandbox escalation approval prompts are allowed to surface.",
    },
    {
      key: "approval_policy.granular.rules",
      type: "boolean",
      description:
        "When `true`, approvals triggered by execpolicy `prompt` rules are allowed to surface.",
    },
    {
      key: "approval_policy.granular.mcp_elicitations",
      type: "boolean",
      description:
        "When `true`, MCP elicitation prompts are allowed to surface instead of being auto-rejected.",
    },
    {
      key: "approval_policy.granular.request_permissions",
      type: "boolean",
      description:
        "When `true`, prompts from the `request_permissions` tool are allowed to surface.",
    },
    {
      key: "approval_policy.granular.skill_approval",
      type: "boolean",
      description:
        "When `true`, skill-script approval prompts are allowed to surface.",
    },
    {
      key: "approvals_reviewer",
      type: "user | auto_review",
      description:
        "Who reviews eligible approval prompts under `on-request` or granular approval policies. Defaults to `user`; `auto_review` uses the reviewer subagent. This setting doesn't change sandboxing or review actions already allowed inside the sandbox.",
    },
    {
      key: "auto_review.policy",
      type: "string",
      description:
        "Local Markdown policy instructions for automatic review. Managed `guardian_policy_config` takes precedence. Blank values are ignored.",
    },
    {
      key: "allow_login_shell",
      type: "boolean",
      description:
        "Allow shell-based tools to use login-shell semantics. Defaults to `true`; when `false`, `login = true` requests are rejected and omitted `login` defaults to non-login shells.",
    },
    {
      key: "sandbox_mode",
      type: "read-only | workspace-write | danger-full-access",
      description:
        "Sandbox policy for filesystem and network access during command execution.",
    },
    {
      key: "sandbox_workspace_write.writable_roots",
      type: "array<string>",
      description:
        'Additional writable roots when `sandbox_mode = "workspace-write"`.',
    },
    {
      key: "sandbox_workspace_write.network_access",
      type: "boolean",
      description:
        "Allow outbound network access inside the workspace-write sandbox.",
    },
    {
      key: "sandbox_workspace_write.exclude_tmpdir_env_var",
      type: "boolean",
      description:
        "Exclude `$TMPDIR` from writable roots in workspace-write mode.",
    },
    {
      key: "sandbox_workspace_write.exclude_slash_tmp",
      type: "boolean",
      description:
        "Exclude `/tmp` from writable roots in workspace-write mode.",
    },
    {
      key: "windows.sandbox",
      type: "unelevated | elevated",
      description:
        "Windows-only native sandbox mode when running Codex natively on Windows.",
    },
    {
      key: "windows.sandbox_private_desktop",
      type: "boolean",
      description:
        "Run the final sandboxed child process on a private desktop by default on native Windows. Set `false` only for compatibility with the older `Winsta0\\\\Default` behavior.",
    },
    {
      key: "notify",
      type: "array<string>",
      description:
        "Command invoked for notifications; receives a JSON payload from Codex.",
    },
    {
      key: "check_for_update_on_startup",
      type: "boolean",
      description:
        "Check for Codex updates on startup (set to false only when updates are centrally managed).",
    },
    {
      key: "feedback.enabled",
      type: "boolean",
      description:
        "Enable feedback submission via `/feedback` across Codex surfaces (default: true).",
    },
    {
      key: "analytics.enabled",
      type: "boolean",
      description:
        "Enable or disable analytics for this machine/profile. When unset, the client default applies.",
    },
    {
      key: "instructions",
      type: "string",
      description:
        "Reserved for future use; prefer `model_instructions_file` or `AGENTS.md`.",
    },
    {
      key: "developer_instructions",
      type: "string",
      description:
        "Additional developer instructions injected into the session (optional).",
    },
    {
      key: "log_dir",
      type: "string (path)",
      description:
        "Directory where Codex writes log files (for example `codex-tui.log`); defaults to `$CODEX_HOME/log`.",
    },
    {
      key: "sqlite_home",
      type: "string (path)",
      description:
        "Directory where Codex stores the SQLite-backed state DB used by agent jobs and other resumable runtime state.",
    },
    {
      key: "compact_prompt",
      type: "string",
      description: "Inline override for the history compaction prompt.",
    },
    {
      key: "commit_attribution",
      type: "string",
      description:
        "Override the commit co-author trailer text. Set an empty string to disable automatic attribution.",
    },
    {
      key: "model_instructions_file",
      type: "string (path)",
      description:
        "Replacement for built-in instructions instead of `AGENTS.md`.",
    },
    {
      key: "personality",
      type: "none | friendly | pragmatic",
      description:
        "Default communication style for models that advertise `supportsPersonality`; can be overridden per thread/turn or via `/personality`.",
    },
    {
      key: "service_tier",
      type: "flex | fast",
      description: "Preferred service tier for new turns.",
    },
    {
      key: "experimental_compact_prompt_file",
      type: "string (path)",
      description:
        "Load the compaction prompt override from a file (experimental).",
    },
    {
      key: "skills.config",
      type: "array<object>",
      description: "Per-skill enablement overrides stored in config.toml.",
    },
    {
      key: "skills.config.<index>.path",
      type: "string (path)",
      description: "Path to a skill folder containing `SKILL.md`.",
    },
    {
      key: "skills.config.<index>.enabled",
      type: "boolean",
      description: "Enable or disable the referenced skill.",
    },
    {
      key: "apps.<id>.enabled",
      type: "boolean",
      description:
        "Enable or disable a specific app/connector by id (default: true).",
    },
    {
      key: "apps._default.enabled",
      type: "boolean",
      description:
        "Default app enabled state for all apps unless overridden per app.",
    },
    {
      key: "apps._default.destructive_enabled",
      type: "boolean",
      description:
        "Default allow/deny for app tools with `destructive_hint = true`.",
    },
    {
      key: "apps._default.open_world_enabled",
      type: "boolean",
      description:
        "Default allow/deny for app tools with `open_world_hint = true`.",
    },
    {
      key: "apps.<id>.destructive_enabled",
      type: "boolean",
      description:
        "Allow or block tools in this app that advertise `destructive_hint = true`.",
    },
    {
      key: "apps.<id>.open_world_enabled",
      type: "boolean",
      description:
        "Allow or block tools in this app that advertise `open_world_hint = true`.",
    },
    {
      key: "apps.<id>.default_tools_enabled",
      type: "boolean",
      description:
        "Default enabled state for tools in this app unless a per-tool override exists.",
    },
    {
      key: "apps.<id>.default_tools_approval_mode",
      type: "auto | prompt | approve",
      description:
        "Default approval behavior for tools in this app unless a per-tool override exists.",
    },
    {
      key: "apps.<id>.tools.<tool>.enabled",
      type: "boolean",
      description:
        "Per-tool enabled override for an app tool (for example `repos/list`).",
    },
    {
      key: "apps.<id>.tools.<tool>.approval_mode",
      type: "auto | prompt | approve",
      description: "Per-tool approval behavior override for a single app tool.",
    },
    {
      key: "tool_suggest.discoverables",
      type: "array<table>",
      description:
        'Allow tool suggestions for additional discoverable connectors or plugins. Each entry uses `type = "connector"` or `"plugin"` and an `id`.',
    },
    {
      key: "tool_suggest.disabled_tools",
      type: "array<table>",
      description:
        'Disable suggestions for specific discoverable connectors or plugins. Each entry uses `type = "connector"` or `"plugin"` and an `id`.',
    },
    {
      key: "features.apps",
      type: "boolean",
      description: "Enable ChatGPT Apps/connectors support (experimental).",
    },
    {
      key: "features.codex_hooks",
      type: "boolean",
      description:
        "Enable lifecycle hooks loaded from `hooks.json` or inline `[hooks]` config.",
    },
    {
      key: "hooks",
      type: "table",
      description:
        "Lifecycle hooks configured inline in `config.toml`. Uses the same event schema as `hooks.json`; see the Hooks guide for examples and supported events.",
    },
    {
      key: "features.memories",
      type: "boolean",
      description: "Enable [Memories](https://developers.openai.com/codex/memories) (off by default).",
    },
    {
      key: "mcp_servers.<id>.command",
      type: "string",
      description: "Launcher command for an MCP stdio server.",
    },
    {
      key: "mcp_servers.<id>.args",
      type: "array<string>",
      description: "Arguments passed to the MCP stdio server command.",
    },
    {
      key: "mcp_servers.<id>.env",
      type: "map<string,string>",
      description: "Environment variables forwarded to the MCP stdio server.",
    },
    {
      key: "mcp_servers.<id>.env_vars",
      type: 'array<string | { name = string, source = "local" | "remote" }>',
      description:
        'Additional environment variables to whitelist for an MCP stdio server. String entries default to `source = "local"`; use `source = "remote"` only with executor-backed remote stdio.',
    },
    {
      key: "mcp_servers.<id>.cwd",
      type: "string",
      description: "Working directory for the MCP stdio server process.",
    },
    {
      key: "mcp_servers.<id>.url",
      type: "string",
      description: "Endpoint for an MCP streamable HTTP server.",
    },
    {
      key: "mcp_servers.<id>.bearer_token_env_var",
      type: "string",
      description:
        "Environment variable sourcing the bearer token for an MCP HTTP server.",
    },
    {
      key: "mcp_servers.<id>.http_headers",
      type: "map<string,string>",
      description: "Static HTTP headers included with each MCP HTTP request.",
    },
    {
      key: "mcp_servers.<id>.env_http_headers",
      type: "map<string,string>",
      description:
        "HTTP headers populated from environment variables for an MCP HTTP server.",
    },
    {
      key: "mcp_servers.<id>.enabled",
      type: "boolean",
      description: "Disable an MCP server without removing its configuration.",
    },
    {
      key: "mcp_servers.<id>.required",
      type: "boolean",
      description:
        "When true, fail startup/resume if this enabled MCP server cannot initialize.",
    },
    {
      key: "mcp_servers.<id>.startup_timeout_sec",
      type: "number",
      description:
        "Override the default 10s startup timeout for an MCP server.",
    },
    {
      key: "mcp_servers.<id>.startup_timeout_ms",
      type: "number",
      description: "Alias for `startup_timeout_sec` in milliseconds.",
    },
    {
      key: "mcp_servers.<id>.tool_timeout_sec",
      type: "number",
      description:
        "Override the default 60s per-tool timeout for an MCP server.",
    },
    {
      key: "mcp_servers.<id>.enabled_tools",
      type: "array<string>",
      description: "Allow list of tool names exposed by the MCP server.",
    },
    {
      key: "mcp_servers.<id>.disabled_tools",
      type: "array<string>",
      description:
        "Deny list applied after `enabled_tools` for the MCP server.",
    },
    {
      key: "mcp_servers.<id>.scopes",
      type: "array<string>",
      description:
        "OAuth scopes to request when authenticating to that MCP server.",
    },
    {
      key: "mcp_servers.<id>.oauth_resource",
      type: "string",
      description:
        "Optional RFC 8707 OAuth resource parameter to include during MCP login.",
    },
    {
      key: "mcp_servers.<id>.experimental_environment",
      type: "local | remote",
      description:
        "Experimental placement for an MCP server. `remote` starts stdio servers through a remote executor environment; streamable HTTP remote placement is not implemented.",
    },
    {
      key: "agents.max_threads",
      type: "number",
      description:
        "Maximum number of agent threads that can be open concurrently. Defaults to `6` when unset.",
    },
    {
      key: "agents.max_depth",
      type: "number",
      description:
        "Maximum nesting depth allowed for spawned agent threads (root sessions start at depth 0; default: 1).",
    },
    {
      key: "agents.job_max_runtime_seconds",
      type: "number",
      description:
        "Default per-worker timeout for `spawn_agents_on_csv` jobs. When unset, the tool falls back to 1800 seconds per worker.",
    },
    {
      key: "agents.<name>.description",
      type: "string",
      description:
        "Role guidance shown to Codex when choosing and spawning that agent type.",
    },
    {
      key: "agents.<name>.config_file",
      type: "string (path)",
      description:
        "Path to a TOML config layer for that role; relative paths resolve from the config file that declares the role.",
    },
    {
      key: "agents.<name>.nickname_candidates",
      type: "array<string>",
      description:
        "Optional pool of display nicknames for spawned agents in that role.",
    },
    {
      key: "memories.generate_memories",
      type: "boolean",
      description:
        "When `false`, newly created threads are not stored as memory-generation inputs. Defaults to `true`.",
    },
    {
      key: "memories.use_memories",
      type: "boolean",
      description:
        "When `false`, Codex skips injecting existing memories into future sessions. Defaults to `true`.",
    },
    {
      key: "memories.disable_on_external_context",
      type: "boolean",
      description:
        "When `true`, threads that use external context such as MCP tool calls, web search, or tool search are kept out of memory generation. Defaults to `false`. Legacy alias: `memories.no_memories_if_mcp_or_web_search`.",
    },
    {
      key: "memories.max_raw_memories_for_consolidation",
      type: "number",
      description:
        "Maximum recent raw memories retained for global consolidation. Defaults to `256` and is capped at `4096`.",
    },
    {
      key: "memories.max_unused_days",
      type: "number",
      description:
        "Maximum days since a memory was last used before it becomes ineligible for consolidation. Defaults to `30` and is clamped to `0`-`365`.",
    },
    {
      key: "memories.max_rollout_age_days",
      type: "number",
      description:
        "Maximum age of threads considered for memory generation. Defaults to `30` and is clamped to `0`-`90`.",
    },
    {
      key: "memories.max_rollouts_per_startup",
      type: "number",
      description:
        "Maximum rollout candidates processed per startup pass. Defaults to `16` and is capped at `128`.",
    },
    {
      key: "memories.min_rollout_idle_hours",
      type: "number",
      description:
        "Minimum idle time before a thread is considered for memory generation. Defaults to `6` and is clamped to `1`-`48`.",
    },
    {
      key: "memories.min_rate_limit_remaining_percent",
      type: "number",
      description:
        "Minimum remaining percentage required in Codex rate-limit windows before memory generation starts. Defaults to `25` and is clamped to `0`-`100`.",
    },
    {
      key: "memories.extract_model",
      type: "string",
      description: "Optional model override for per-thread memory extraction.",
    },
    {
      key: "memories.consolidation_model",
      type: "string",
      description: "Optional model override for global memory consolidation.",
    },
    {
      key: "features.unified_exec",
      type: "boolean",
      description:
        "Use the unified PTY-backed exec tool (stable; enabled by default except on Windows).",
    },
    {
      key: "features.shell_snapshot",
      type: "boolean",
      description:
        "Snapshot shell environment to speed up repeated commands (stable; on by default).",
    },
    {
      key: "features.undo",
      type: "boolean",
      description: "Enable undo support (stable; off by default).",
    },
    {
      key: "features.multi_agent",
      type: "boolean",
      description:
        "Enable multi-agent collaboration tools (`spawn_agent`, `send_input`, `resume_agent`, `wait_agent`, and `close_agent`) (stable; on by default).",
    },
    {
      key: "features.personality",
      type: "boolean",
      description:
        "Enable personality selection controls (stable; on by default).",
    },
    {
      key: "features.web_search",
      type: "boolean",
      description:
        "Deprecated legacy toggle; prefer the top-level `web_search` setting.",
    },
    {
      key: "features.web_search_cached",
      type: "boolean",
      description:
        'Deprecated legacy toggle. When `web_search` is unset, true maps to `web_search = "cached"`.',
    },
    {
      key: "features.web_search_request",
      type: "boolean",
      description:
        'Deprecated legacy toggle. When `web_search` is unset, true maps to `web_search = "live"`.',
    },
    {
      key: "features.shell_tool",
      type: "boolean",
      description:
        "Enable the default `shell` tool for running commands (stable; on by default).",
    },
    {
      key: "features.enable_request_compression",
      type: "boolean",
      description:
        "Compress streaming request bodies with zstd when supported (stable; on by default).",
    },
    {
      key: "features.skill_mcp_dependency_install",
      type: "boolean",
      description:
        "Allow prompting and installing missing MCP dependencies for skills (stable; on by default).",
    },
    {
      key: "features.fast_mode",
      type: "boolean",
      description:
        'Enable Fast mode selection and the `service_tier = "fast"` path (stable; on by default).',
    },
    {
      key: "features.prevent_idle_sleep",
      type: "boolean",
      description:
        "Prevent the machine from sleeping while a turn is actively running (experimental; off by default).",
    },
    {
      key: "suppress_unstable_features_warning",
      type: "boolean",
      description:
        "Suppress the warning that appears when under-development feature flags are enabled.",
    },
    {
      key: "model_providers.<id>",
      type: "table",
      description:
        "Custom provider definition. Built-in provider IDs (`openai`, `ollama`, and `lmstudio`) are reserved and cannot be overridden.",
    },
    {
      key: "model_providers.<id>.name",
      type: "string",
      description: "Display name for a custom model provider.",
    },
    {
      key: "model_providers.<id>.base_url",
      type: "string",
      description: "API base URL for the model provider.",
    },
    {
      key: "model_providers.<id>.env_key",
      type: "string",
      description: "Environment variable supplying the provider API key.",
    },
    {
      key: "model_providers.<id>.env_key_instructions",
      type: "string",
      description: "Optional setup guidance for the provider API key.",
    },
    {
      key: "model_providers.<id>.experimental_bearer_token",
      type: "string",
      description:
        "Direct bearer token for the provider (discouraged; use `env_key`).",
    },
    {
      key: "model_providers.<id>.requires_openai_auth",
      type: "boolean",
      description:
        "The provider uses OpenAI authentication (defaults to false).",
    },
    {
      key: "model_providers.<id>.wire_api",
      type: "responses",
      description:
        "Protocol used by the provider. `responses` is the only supported value, and it is the default when omitted.",
    },
    {
      key: "model_providers.<id>.query_params",
      type: "map<string,string>",
      description: "Extra query parameters appended to provider requests.",
    },
    {
      key: "model_providers.<id>.http_headers",
      type: "map<string,string>",
      description: "Static HTTP headers added to provider requests.",
    },
    {
      key: "model_providers.<id>.env_http_headers",
      type: "map<string,string>",
      description:
        "HTTP headers populated from environment variables when present.",
    },
    {
      key: "model_providers.<id>.request_max_retries",
      type: "number",
      description:
        "Retry count for HTTP requests to the provider (default: 4).",
    },
    {
      key: "model_providers.<id>.stream_max_retries",
      type: "number",
      description: "Retry count for SSE streaming interruptions (default: 5).",
    },
    {
      key: "model_providers.<id>.stream_idle_timeout_ms",
      type: "number",
      description:
        "Idle timeout for SSE streams in milliseconds (default: 300000).",
    },
    {
      key: "model_providers.<id>.supports_websockets",
      type: "boolean",
      description:
        "Whether that provider supports the Responses API WebSocket transport.",
    },
    {
      key: "model_providers.<id>.auth",
      type: "table",
      description:
        "Command-backed bearer token configuration for a custom provider. Do not combine with `env_key`, `experimental_bearer_token`, or `requires_openai_auth`.",
    },
    {
      key: "model_providers.<id>.auth.command",
      type: "string",
      description:
        "Command to run when Codex needs a bearer token. The command must print the token to stdout.",
    },
    {
      key: "model_providers.<id>.auth.args",
      type: "array<string>",
      description: "Arguments passed to the token command.",
    },
    {
      key: "model_providers.<id>.auth.timeout_ms",
      type: "number",
      description:
        "Maximum token command runtime in milliseconds (default: 5000).",
    },
    {
      key: "model_providers.<id>.auth.refresh_interval_ms",
      type: "number",
      description:
        "How often Codex proactively refreshes the token in milliseconds (default: 300000). Set to `0` to refresh only after an authentication retry.",
    },
    {
      key: "model_providers.<id>.auth.cwd",
      type: "string (path)",
      description: "Working directory for the token command.",
    },
    {
      key: "model_providers.amazon-bedrock.aws.profile",
      type: "string",
      description:
        "AWS profile name used by the built-in `amazon-bedrock` provider.",
    },
    {
      key: "model_providers.amazon-bedrock.aws.region",
      type: "string",
      description: "AWS region used by the built-in `amazon-bedrock` provider.",
    },
    {
      key: "model_reasoning_effort",
      type: "minimal | low | medium | high | xhigh",
      description:
        "Adjust reasoning effort for supported models (Responses API only; `xhigh` is model-dependent).",
    },
    {
      key: "plan_mode_reasoning_effort",
      type: "none | minimal | low | medium | high | xhigh",
      description:
        "Plan-mode-specific reasoning override. When unset, Plan mode uses its built-in preset default.",
    },
    {
      key: "model_reasoning_summary",
      type: "auto | concise | detailed | none",
      description:
        "Select reasoning summary detail or disable summaries entirely.",
    },
    {
      key: "model_verbosity",
      type: "low | medium | high",
      description:
        "Optional GPT-5 Responses API verbosity override; when unset, the selected model/preset default is used.",
    },
    {
      key: "model_supports_reasoning_summaries",
      type: "boolean",
      description: "Force Codex to send or not send reasoning metadata.",
    },
    {
      key: "shell_environment_policy.inherit",
      type: "all | core | none",
      description:
        "Baseline environment inheritance when spawning subprocesses.",
    },
    {
      key: "shell_environment_policy.ignore_default_excludes",
      type: "boolean",
      description:
        "Keep variables containing KEY/SECRET/TOKEN before other filters run.",
    },
    {
      key: "shell_environment_policy.exclude",
      type: "array<string>",
      description:
        "Glob patterns for removing environment variables after the defaults.",
    },
    {
      key: "shell_environment_policy.include_only",
      type: "array<string>",
      description:
        "Whitelist of patterns; when set only matching variables are kept.",
    },
    {
      key: "shell_environment_policy.set",
      type: "map<string,string>",
      description:
        "Explicit environment overrides injected into every subprocess.",
    },
    {
      key: "shell_environment_policy.experimental_use_profile",
      type: "boolean",
      description: "Use the user shell profile when spawning subprocesses.",
    },
    {
      key: "project_root_markers",
      type: "array<string>",
      description:
        "List of project root marker filenames; used when searching parent directories for the project root.",
    },
    {
      key: "project_doc_max_bytes",
      type: "number",
      description:
        "Maximum bytes read from `AGENTS.md` when building project instructions.",
    },
    {
      key: "project_doc_fallback_filenames",
      type: "array<string>",
      description: "Additional filenames to try when `AGENTS.md` is missing.",
    },
    {
      key: "profile",
      type: "string",
      description:
        "Default profile applied at startup (equivalent to `--profile`).",
    },
    {
      key: "profiles.<name>.*",
      type: "various",
      description:
        "Profile-scoped overrides for any of the supported configuration keys.",
    },
    {
      key: "profiles.<name>.service_tier",
      type: "flex | fast",
      description: "Profile-scoped service tier preference for new turns.",
    },
    {
      key: "profiles.<name>.plan_mode_reasoning_effort",
      type: "none | minimal | low | medium | high | xhigh",
      description: "Profile-scoped Plan-mode reasoning override.",
    },
    {
      key: "profiles.<name>.web_search",
      type: "disabled | cached | live",
      description:
        'Profile-scoped web search mode override (default: `"cached"`).',
    },
    {
      key: "profiles.<name>.personality",
      type: "none | friendly | pragmatic",
      description:
        "Profile-scoped communication style override for supported models.",
    },
    {
      key: "profiles.<name>.model_catalog_json",
      type: "string (path)",
      description:
        "Profile-scoped model catalog JSON path override (applied on startup only; overrides the top-level `model_catalog_json` for that profile).",
    },
    {
      key: "profiles.<name>.model_instructions_file",
      type: "string (path)",
      description:
        "Profile-scoped replacement for the built-in instruction file.",
    },
    {
      key: "profiles.<name>.experimental_use_unified_exec_tool",
      type: "boolean",
      description:
        "Legacy name for enabling unified exec; prefer `[features].unified_exec`.",
    },
    {
      key: "profiles.<name>.oss_provider",
      type: "lmstudio | ollama",
      description: "Profile-scoped OSS provider for `--oss` sessions.",
    },
    {
      key: "profiles.<name>.tools_view_image",
      type: "boolean",
      description: "Enable or disable the `view_image` tool in that profile.",
    },
    {
      key: "profiles.<name>.analytics.enabled",
      type: "boolean",
      description: "Profile-scoped analytics enablement override.",
    },
    {
      key: "profiles.<name>.windows.sandbox",
      type: "unelevated | elevated",
      description: "Profile-scoped Windows sandbox mode override.",
    },
    {
      key: "history.persistence",
      type: "save-all | none",
      description:
        "Control whether Codex saves session transcripts to history.jsonl.",
    },
    {
      key: "tool_output_token_limit",
      type: "number",
      description:
        "Token budget for storing individual tool/function outputs in history.",
    },
    {
      key: "background_terminal_max_timeout",
      type: "number",
      description:
        "Maximum poll window in milliseconds for empty `write_stdin` polls (background terminal polling). Default: `300000` (5 minutes). Replaces the older `background_terminal_timeout` key.",
    },
    {
      key: "history.max_bytes",
      type: "number",
      description:
        "If set, caps the history file size in bytes by dropping oldest entries.",
    },
    {
      key: "file_opener",
      type: "vscode | vscode-insiders | windsurf | cursor | none",
      description:
        "URI scheme used to open citations from Codex output (default: `vscode`).",
    },
    {
      key: "otel.environment",
      type: "string",
      description:
        "Environment tag applied to emitted OpenTelemetry events (default: `dev`).",
    },
    {
      key: "otel.exporter",
      type: "none | otlp-http | otlp-grpc",
      description:
        "Select the OpenTelemetry exporter and provide any endpoint metadata.",
    },
    {
      key: "otel.trace_exporter",
      type: "none | otlp-http | otlp-grpc",
      description:
        "Select the OpenTelemetry trace exporter and provide any endpoint metadata.",
    },
    {
      key: "otel.metrics_exporter",
      type: "none | statsig | otlp-http | otlp-grpc",
      description:
        "Select the OpenTelemetry metrics exporter (defaults to `statsig`).",
    },
    {
      key: "otel.log_user_prompt",
      type: "boolean",
      description:
        "Opt in to exporting raw user prompts with OpenTelemetry logs.",
    },
    {
      key: "otel.exporter.<id>.endpoint",
      type: "string",
      description: "Exporter endpoint for OTEL logs.",
    },
    {
      key: "otel.exporter.<id>.protocol",
      type: "binary | json",
      description: "Protocol used by the OTLP/HTTP exporter.",
    },
    {
      key: "otel.exporter.<id>.headers",
      type: "map<string,string>",
      description: "Static headers included with OTEL exporter requests.",
    },
    {
      key: "otel.trace_exporter.<id>.endpoint",
      type: "string",
      description: "Trace exporter endpoint for OTEL logs.",
    },
    {
      key: "otel.trace_exporter.<id>.protocol",
      type: "binary | json",
      description: "Protocol used by the OTLP/HTTP trace exporter.",
    },
    {
      key: "otel.trace_exporter.<id>.headers",
      type: "map<string,string>",
      description: "Static headers included with OTEL trace exporter requests.",
    },
    {
      key: "otel.exporter.<id>.tls.ca-certificate",
      type: "string",
      description: "CA certificate path for OTEL exporter TLS.",
    },
    {
      key: "otel.exporter.<id>.tls.client-certificate",
      type: "string",
      description: "Client certificate path for OTEL exporter TLS.",
    },
    {
      key: "otel.exporter.<id>.tls.client-private-key",
      type: "string",
      description: "Client private key path for OTEL exporter TLS.",
    },
    {
      key: "otel.trace_exporter.<id>.tls.ca-certificate",
      type: "string",
      description: "CA certificate path for OTEL trace exporter TLS.",
    },
    {
      key: "otel.trace_exporter.<id>.tls.client-certificate",
      type: "string",
      description: "Client certificate path for OTEL trace exporter TLS.",
    },
    {
      key: "otel.trace_exporter.<id>.tls.client-private-key",
      type: "string",
      description: "Client private key path for OTEL trace exporter TLS.",
    },
    {
      key: "tui",
      type: "table",
      description:
        "TUI-specific options such as enabling inline desktop notifications.",
    },
    {
      key: "tui.notifications",
      type: "boolean | array<string>",
      description:
        "Enable TUI notifications; optionally restrict to specific event types.",
    },
    {
      key: "tui.notification_method",
      type: "auto | osc9 | bel",
      description:
        "Notification method for terminal notifications (default: auto).",
    },
    {
      key: "tui.notification_condition",
      type: "unfocused | always",
      description:
        "Control whether TUI notifications fire only when the terminal is unfocused or regardless of focus. Defaults to `unfocused`.",
    },
    {
      key: "tui.animations",
      type: "boolean",
      description:
        "Enable terminal animations (welcome screen, shimmer, spinner) (default: true).",
    },
    {
      key: "tui.alternate_screen",
      type: "auto | always | never",
      description:
        "Control alternate screen usage for the TUI (default: auto; auto skips it in Zellij to preserve scrollback).",
    },
    {
      key: "tui.show_tooltips",
      type: "boolean",
      description:
        "Show onboarding tooltips in the TUI welcome screen (default: true).",
    },
    {
      key: "tui.status_line",
      type: "array<string> | null",
      description:
        "Ordered list of TUI footer status-line item identifiers. `null` disables the status line.",
    },
    {
      key: "tui.terminal_title",
      type: "array<string> | null",
      description:
        'Ordered list of terminal window/tab title item identifiers. Defaults to `["spinner", "project"]`; `null` disables title updates.',
    },
    {
      key: "tui.theme",
      type: "string",
      description:
        "Syntax-highlighting theme override (kebab-case theme name).",
    },
    {
      key: "tui.keymap.<context>.<action>",
      type: "string | array<string>",
      description:
        "Keyboard shortcut binding for a TUI action. Supported contexts include `global`, `chat`, `composer`, `editor`, `pager`, `list`, and `approval`; context-specific bindings override `tui.keymap.global`.",
    },
    {
      key: "tui.keymap.<context>.<action> = []",
      type: "empty array",
      description:
        "Unbind the action in that keymap context. Key names use normalized strings such as `ctrl-a`, `shift-enter`, or `page-down`.",
    },
    {
      key: "tui.model_availability_nux.<model>",
      type: "integer",
      description: "Internal startup-tooltip state keyed by model slug.",
    },
    {
      key: "hide_agent_reasoning",
      type: "boolean",
      description:
        "Suppress reasoning events in both the TUI and `codex exec` output.",
    },
    {
      key: "show_raw_agent_reasoning",
      type: "boolean",
      description:
        "Surface raw reasoning content when the active model emits it.",
    },
    {
      key: "disable_paste_burst",
      type: "boolean",
      description: "Disable burst-paste detection in the TUI.",
    },
    {
      key: "windows_wsl_setup_acknowledged",
      type: "boolean",
      description: "Track Windows onboarding acknowledgement (Windows only).",
    },
    {
      key: "chatgpt_base_url",
      type: "string",
      description: "Override the base URL used during the ChatGPT login flow.",
    },
    {
      key: "cli_auth_credentials_store",
      type: "file | keyring | auto",
      description:
        "Control where the CLI stores cached credentials (file-based auth.json vs OS keychain).",
    },
    {
      key: "mcp_oauth_credentials_store",
      type: "auto | file | keyring",
      description: "Preferred store for MCP OAuth credentials.",
    },
    {
      key: "mcp_oauth_callback_port",
      type: "integer",
      description:
        "Optional fixed port for the local HTTP callback server used during MCP OAuth login. When unset, Codex binds to an ephemeral port chosen by the OS.",
    },
    {
      key: "mcp_oauth_callback_url",
      type: "string",
      description:
        "Optional redirect URI override for MCP OAuth login (for example, a devbox ingress URL). `mcp_oauth_callback_port` still controls the callback listener port.",
    },
    {
      key: "experimental_use_unified_exec_tool",
      type: "boolean",
      description:
        "Legacy name for enabling unified exec; prefer `[features].unified_exec` or `codex --enable unified_exec`.",
    },
    {
      key: "tools.web_search",
      type: 'boolean | { context_size = "low|medium|high", allowed_domains = [string], location = { country, region, city, timezone } }',
      description:
        "Optional web search tool configuration. The legacy boolean form is still accepted, but the object form lets you set search context size, allowed domains, and approximate user location.",
    },
    {
      key: "tools.view_image",
      type: "boolean",
      description: "Enable the local-image attachment tool `view_image`.",
    },
    {
      key: "web_search",
      type: "disabled | cached | live",
      description:
        'Web search mode (default: `"cached"`; cached uses an OpenAI-maintained index and does not fetch live pages; if you use `--yolo` or another full access sandbox setting, it defaults to `"live"`). Use `"live"` to fetch the most recent data from the web, or `"disabled"` to remove the tool.',
    },
    {
      key: "default_permissions",
      type: "string",
      description:
        "Name of the default permissions profile to apply to sandboxed tool calls. Built-ins are `:read-only`, `:workspace`, and `:danger-no-sandbox`; custom profile names require matching `[permissions.<name>]` tables.",
    },
    {
      key: "permissions.<name>.filesystem",
      type: "table",
      description:
        "Named filesystem permission profile. Each key is an absolute path or special token such as `:minimal` or `:project_roots`.",
    },
    {
      key: "permissions.<name>.filesystem.glob_scan_max_depth",
      type: "number",
      description:
        "Maximum depth for expanding deny-read glob patterns on platforms that snapshot matches before sandbox startup. Must be at least `1` when set.",
    },
    {
      key: "permissions.<name>.filesystem.<path-or-glob>",
      type: '"read" | "write" | "none" | table',
      description:
        'Grant direct access for a path, glob pattern, or special token, or scope nested entries under that root. Use `"none"` to deny reads for matching paths.',
    },
    {
      key: 'permissions.<name>.filesystem.":project_roots".<subpath-or-glob>',
      type: '"read" | "write" | "none"',
      description:
        'Scoped filesystem access relative to the detected project roots. Use `"."` for the root itself; glob subpaths such as `"**/*.env"` can deny reads with `"none"`.',
    },
    {
      key: "permissions.<name>.network.enabled",
      type: "boolean",
      description: "Enable network access for this named permissions profile.",
    },
    {
      key: "permissions.<name>.network.proxy_url",
      type: "string",
      description:
        "HTTP proxy endpoint used when this permissions profile enables the managed network proxy.",
    },
    {
      key: "permissions.<name>.network.enable_socks5",
      type: "boolean",
      description:
        "Expose a SOCKS5 listener when this permissions profile enables the managed network proxy.",
    },
    {
      key: "permissions.<name>.network.socks_url",
      type: "string",
      description: "SOCKS5 proxy endpoint used by this permissions profile.",
    },
    {
      key: "permissions.<name>.network.enable_socks5_udp",
      type: "boolean",
      description: "Allow UDP over the SOCKS5 listener when enabled.",
    },
    {
      key: "permissions.<name>.network.allow_upstream_proxy",
      type: "boolean",
      description:
        "Allow the managed proxy to chain to another upstream proxy.",
    },
    {
      key: "permissions.<name>.network.dangerously_allow_non_loopback_proxy",
      type: "boolean",
      description:
        "Permit non-loopback bind addresses for the managed proxy listener.",
    },
    {
      key: "permissions.<name>.network.dangerously_allow_all_unix_sockets",
      type: "boolean",
      description:
        "Allow the proxy to use arbitrary Unix sockets instead of the default restricted set.",
    },
    {
      key: "permissions.<name>.network.mode",
      type: "limited | full",
      description: "Network proxy mode used for subprocess traffic.",
    },
    {
      key: "permissions.<name>.network.domains",
      type: "map<string, allow | deny>",
      description:
        "Domain rules for the managed proxy. Use domain names or wildcard patterns as keys, with `allow` or `deny` values.",
    },
    {
      key: "permissions.<name>.network.unix_sockets",
      type: "map<string, allow | none>",
      description:
        "Unix socket rules for the managed proxy. Use socket paths as keys, with `allow` or `none` values.",
    },
    {
      key: "permissions.<name>.network.allow_local_binding",
      type: "boolean",
      description:
        "Permit local bind/listen operations through the managed proxy.",
    },
    {
      key: "projects.<path>.trust_level",
      type: "string",
      description:
        'Mark a project or worktree as trusted or untrusted (`"trusted"` | `"untrusted"`). Untrusted projects skip project-scoped `.codex/` layers, including project-local config, hooks, and rules.',
    },
    {
      key: "notice.hide_full_access_warning",
      type: "boolean",
      description: "Track acknowledgement of the full access warning prompt.",
    },
    {
      key: "notice.hide_world_writable_warning",
      type: "boolean",
      description:
        "Track acknowledgement of the Windows world-writable directories warning.",
    },
    {
      key: "notice.hide_rate_limit_model_nudge",
      type: "boolean",
      description: "Track opt-out of the rate limit model switch reminder.",
    },
    {
      key: "notice.hide_gpt5_1_migration_prompt",
      type: "boolean",
      description: "Track acknowledgement of the GPT-5.1 migration prompt.",
    },
    {
      key: "notice.hide_gpt-5.1-codex-max_migration_prompt",
      type: "boolean",
      description:
        "Track acknowledgement of the gpt-5.1-codex-max migration prompt.",
    },
    {
      key: "notice.model_migrations",
      type: "map<string,string>",
      description: "Track acknowledged model migrations as old->new mappings.",
    },
    {
      key: "forced_login_method",
      type: "chatgpt | api",
      description: "Restrict Codex to a specific authentication method.",
    },
    {
      key: "forced_chatgpt_workspace_id",
      type: "string (uuid)",
      description: "Limit ChatGPT logins to a specific workspace identifier.",
    },
  ]}
  client:load
/>

You can find the latest JSON schema for `config.toml` [here](https://developers.openai.com/codex/config-schema.json).

To get autocompletion and diagnostics when editing `config.toml` in VS Code or Cursor, you can install the [Even Better TOML](https://marketplace.visualstudio.com/items?itemName=tamasfe.even-better-toml) extension and add this line to the top of your `config.toml`:

```toml
#:schema https://developers.openai.com/codex/config-schema.json
```

Note: Rename `experimental_instructions_file` to `model_instructions_file`. Codex deprecates the old key; update existing configs to the new name.

## `requirements.toml`

`requirements.toml` is an admin-enforced configuration file that constrains security-sensitive settings users can't override. For details, locations, and examples, see [Admin-enforced requirements](https://developers.openai.com/codex/enterprise/managed-configuration#admin-enforced-requirements-requirementstoml).

For ChatGPT Business and Enterprise users, Codex can also apply cloud-fetched
requirements. See the security page for precedence details.

Use `[features]` in `requirements.toml` to pin feature flags by the same
canonical keys that `config.toml` uses. Omitted keys remain unconstrained.

<ConfigTable
  options={[
    {
      key: "allowed_approval_policies",
      type: "array<string>",
      description:
        "Allowed values for `approval_policy` (for example `untrusted`, `on-request`, `never`, and `granular`).",
    },
    {
      key: "allowed_approvals_reviewers",
      type: "array<string>",
      description:
        "Allowed values for `approvals_reviewer`, such as `user` and `auto_review`.",
    },
    {
      key: "guardian_policy_config",
      type: "string",
      description:
        "Managed Markdown policy instructions for automatic review. This takes precedence over local `[auto_review].policy`. Blank values are ignored.",
    },
    {
      key: "allowed_sandbox_modes",
      type: "array<string>",
      description: "Allowed values for `sandbox_mode`.",
    },
    {
      key: "remote_sandbox_config",
      type: "array<table>",
      description:
        "Host-specific sandbox requirements. The first entry whose `hostname_patterns` match the resolved host name overrides top-level `allowed_sandbox_modes` for that requirements source. Host-specific entries currently override sandbox modes only.",
    },
    {
      key: "remote_sandbox_config[].hostname_patterns",
      type: "array<string>",
      description:
        "Case-insensitive host name patterns. Supports `*` for any sequence of characters and `?` for one character.",
    },
    {
      key: "remote_sandbox_config[].allowed_sandbox_modes",
      type: "array<string>",
      description:
        "Allowed sandbox modes to apply when this host-specific entry matches.",
    },
    {
      key: "allowed_web_search_modes",
      type: "array<string>",
      description:
        "Allowed values for `web_search` (`disabled`, `cached`, `live`). `disabled` is always allowed; an empty list effectively allows only `disabled`.",
    },
    {
      key: "features",
      type: "table",
      description:
        "Pinned feature values keyed by the canonical names from `config.toml`'s `[features]` table.",
    },
    {
      key: "features.<name>",
      type: "boolean",
      description:
        "Require a specific canonical feature key to stay enabled or disabled.",
    },
    {
      key: "features.in_app_browser",
      type: "boolean",
      description:
        "Set to `false` in `requirements.toml` to disable the in-app browser pane.",
    },
    {
      key: "features.browser_use",
      type: "boolean",
      description:
        "Set to `false` in `requirements.toml` to disable Browser Use and Browser Agent availability.",
    },
    {
      key: "features.computer_use",
      type: "boolean",
      description:
        "Set to `false` in `requirements.toml` to disable Computer Use availability and related install or enablement flows.",
    },
    {
      key: "hooks",
      type: "table",
      description:
        "Admin-enforced managed lifecycle hooks. Requires a managed hook directory and uses the same event schema as inline `[hooks]` in `config.toml`.",
    },
    {
      key: "hooks.managed_dir",
      type: "string (absolute path)",
      description:
        "Directory containing managed hook scripts on macOS and Linux. Codex validates that it is absolute and exists before loading managed hooks.",
    },
    {
      key: "hooks.windows_managed_dir",
      type: "string (absolute path)",
      description:
        "Directory containing managed hook scripts on Windows. Codex validates that it is absolute and exists before loading managed hooks.",
    },
    {
      key: "hooks.<Event>",
      type: "array<table>",
      description:
        "Matcher groups for a hook event such as `PreToolUse`, `PostToolUse`, `PermissionRequest`, `SessionStart`, `UserPromptSubmit`, or `Stop`.",
    },
    {
      key: "hooks.<Event>[].hooks",
      type: "array<table>",
      description:
        "Hook handlers for a matcher group. Command hooks are currently supported; prompt and agent hook handlers are parsed but skipped.",
    },
    {
      key: "permissions.filesystem.deny_read",
      type: "array<string>",
      description:
        "Admin-enforced filesystem read denials. Entries can be paths or glob patterns, and users cannot weaken them with local config.",
    },
    {
      key: "mcp_servers",
      type: "table",
      description:
        "Allowlist of MCP servers that may be enabled. Both the server name (`<id>`) and its identity must match for the MCP server to be enabled. Any configured MCP server not in the allowlist (or with a mismatched identity) is disabled.",
    },
    {
      key: "mcp_servers.<id>.identity",
      type: "table",
      description:
        "Identity rule for a single MCP server. Set either `command` (stdio) or `url` (streamable HTTP).",
    },
    {
      key: "mcp_servers.<id>.identity.command",
      type: "string",
      description:
        "Allow an MCP stdio server when its `mcp_servers.<id>.command` matches this command.",
    },
    {
      key: "mcp_servers.<id>.identity.url",
      type: "string",
      description:
        "Allow an MCP streamable HTTP server when its `mcp_servers.<id>.url` matches this URL.",
    },
    {
      key: "rules",
      type: "table",
      description:
        "Admin-enforced command rules merged with `.rules` files. Requirements rules must be restrictive.",
    },
    {
      key: "rules.prefix_rules",
      type: "array<table>",
      description:
        "List of enforced prefix rules. Each rule must include `pattern` and `decision`.",
    },
    {
      key: "rules.prefix_rules[].pattern",
      type: "array<table>",
      description:
        "Command prefix expressed as pattern tokens. Each token sets either `token` or `any_of`.",
    },
    {
      key: "rules.prefix_rules[].pattern[].token",
      type: "string",
      description: "A single literal token at this position.",
    },
    {
      key: "rules.prefix_rules[].pattern[].any_of",
      type: "array<string>",
      description: "A list of allowed alternative tokens at this position.",
    },
    {
      key: "rules.prefix_rules[].decision",
      type: "prompt | forbidden",
      description:
        "Required. Requirements rules can only prompt or forbid (not allow).",
    },
    {
      key: "rules.prefix_rules[].justification",
      type: "string",
      description:
        "Optional non-empty rationale surfaced in approval prompts or rejection messages.",
    },
  ]}
  client:load
/>