# Parameters

## Global options

Global options can be used with any command:

OptionDescription`-v, --version`Output the version number`--api-key <key>`API key for authentication (can also use `CURSOR_API_KEY` env var)`-H, --header <header>`Add custom header to agent requests (format: `Name: Value`, can be used multiple times)`-p, --print`Print responses to console (for scripts or non-interactive use). Has access to all tools, including write and shell.`--output-format <format>`Output format (only works with `--print`): `text`, `json`, or `stream-json` (default: `text`)`--stream-partial-output`Stream partial output as individual text deltas (only works with `--print` and `stream-json` format)`--resume [chatId]`Resume a chat session`--continue`Continue the previous session (alias for `--resume=-1`)`--model <model>`Model to use`--mode <mode>`Set agent mode: `plan` or `ask` (agent is the default when no mode is specified)`--plan`Start in plan mode (shorthand for `--mode=plan`)`--list-models`List all available models`-f, --force`Force allow commands unless explicitly denied`--yolo`Alias for `--force``--sandbox <mode>`Set sandbox mode: `enabled` or `disabled``--approve-mcps`Automatically approve all MCP servers`--trust`Trust the workspace without prompting (headless mode only)`--workspace <path>`Workspace directory to use`--worktree`Run in a new Git worktree under `~/.cursor/worktrees` (see [CLI worktrees](/docs/cli/using#cli-worktrees))`-h, --help`Display help for command
## Commands

CommandDescriptionUsage`agent`Start in agent mode (the default)`agent agent``login`Authenticate with Cursor`agent login``logout`Sign out and clear stored authentication`agent logout``status` | `whoami`Check authentication status`agent status``about`Display version, system, and account info`agent about``models`List all available models`agent models``mcp`Manage MCP servers`agent mcp``acp`Start ACP server mode (advanced, hidden command)`agent acp``update`Update Cursor Agent to the latest version`agent update``ls`List previous chat sessions`agent ls``resume`Resume the latest chat session`agent resume``create-chat`Create a new empty chat and return its ID`agent create-chat``generate-rule` | `rule`Generate a new Cursor rule interactively`agent generate-rule``install-shell-integration`Install shell integration to `~/.zshrc``agent install-shell-integration``uninstall-shell-integration`Remove shell integration from `~/.zshrc``agent uninstall-shell-integration``help [command]`Display help for command`agent help [command]`
`agent acp` is intended for custom ACP clients and advanced integrations. It is
hidden from default command help output.

When no command is specified, Cursor Agent starts in interactive agent mode by
default.

## MCP

Manage MCP servers configured for Cursor Agent.

SubcommandDescriptionUsage`login <identifier>`Authenticate with an MCP server configured in `.cursor/mcp.json``agent mcp login <identifier>``list`List configured MCP servers and their status`agent mcp list``list-tools <identifier>`List available tools and their argument names for a specific MCP`agent mcp list-tools <identifier>``enable <identifier>`Enable an MCP server`agent mcp enable <identifier>``disable <identifier>`Disable an MCP server`agent mcp disable <identifier>`
All MCP commands support `-h, --help` for command-specific help.

## Arguments

When starting in chat mode (default behavior), you can provide an initial prompt:

**Arguments:**

- `prompt` — Initial prompt for the agent

## Getting help

All commands support the global `-h, --help` option to display command-specific help.