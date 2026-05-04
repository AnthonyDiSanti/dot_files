# Configuration

Configure the Agent CLI using the `cli-config.json` file.

## File location

TypePlatformPathGlobalmacOS/Linux`~/.cursor/cli-config.json`GlobalWindows`$env:USERPROFILE\.cursor\cli-config.json`ProjectAll`<project>/.cursor/cli.json`
Only permissions can be configured at the project level. All other CLI
settings must be set globally.

Override with environment variables:

- **`CURSOR_CONFIG_DIR`**: custom directory path
- **`XDG_CONFIG_HOME`** (Linux/BSD): uses `$XDG_CONFIG_HOME/cursor/cli-config.json`

## Schema

### Required fields

FieldTypeDescription`version`numberConfig schema version (current: `1`)`editor.vimMode`booleanEnable Vim keybindings (default: `false`)`permissions.allow`string[]Permitted operations (see [Permissions](/docs/cli/reference/permissions))`permissions.deny`string[]Forbidden operations (see [Permissions](/docs/cli/reference/permissions))
### Optional fields

FieldTypeDescription`model`objectSelected model configuration`hasChangedDefaultModel`booleanCLI-managed model override flag`network.useHttp1ForAgent`booleanUse HTTP/1.1 instead of HTTP/2 for agent connections (default: `false`)`attribution.attributeCommitsToAgent`booleanAdd "Made with Cursor" trailer to Agent commits (default: `true`)`attribution.attributePRsToAgent`booleanAdd "Made with Cursor" footer to Agent PRs (default: `true`)
## Examples

### Minimal config

```
{
  "version": 1,
  "editor": { "vimMode": false },
  "permissions": { "allow": ["Shell(ls)"], "deny": [] }
}
```

### Enable Vim mode

```
{
  "version": 1,
  "editor": { "vimMode": true },
  "permissions": { "allow": ["Shell(ls)"], "deny": [] }
}
```

### Configure permissions

```
{
  "version": 1,
  "editor": { "vimMode": false },
  "permissions": {
    "allow": ["Shell(ls)", "Shell(echo)"],
    "deny": ["Shell(rm)"]
  }
}
```

See [Permissions](/docs/cli/reference/permissions) for available permission types and examples.

## Troubleshooting

**Config errors**: Move the file aside and restart:

```
mv ~/.cursor/cli-config.json ~/.cursor/cli-config.json.bad
```

**Changes don't persist**: Ensure valid JSON and write permissions. Some fields are CLI-managed and may be overwritten.

## Notes

- Pure JSON format (no comments)
- CLI performs self-repair for missing fields
- Corrupted files are backed up as `.bad` and recreated
- Permission entries are exact strings (see [Permissions](/docs/cli/reference/permissions) for details)

## Models

You can select a model for the CLI using the `/model` slash command.

```
/model auto
/model gpt-5.2
/model sonnet-4.5-thinking
```

See the [Slash commands](/docs/cli/reference/slash-commands) docs for other commands.

## Proxy configuration

If your network routes traffic through a proxy server, configure the CLI using environment variables and the config file.

### Environment variables

Set these environment variables before running the CLI:

```
export HTTP_PROXY=http://your-proxy:port
export HTTPS_PROXY=http://your-proxy:port
export NODE_USE_ENV_PROXY=1
```

If your proxy performs SSL inspection (man-in-the-middle), also trust your organization's CA certificate:

```
export NODE_EXTRA_CA_CERTS=/path/to/corporate-ca-cert.pem
```

### HTTP/1.1 fallback

Some enterprise proxies (like Zscaler) don't support HTTP/2 bidirectional streaming. Enable HTTP/1.1 mode in your config:

```
{
  "version": 1,
  "editor": { "vimMode": false },
  "permissions": { "allow": [], "deny": [] },
  "network": {
    "useHttp1ForAgent": true
  }
}
```

This switches agent connections to HTTP/1.1 with Server-Sent Events (SSE), which works with most corporate proxies.

See [Network Configuration](/docs/enterprise/network-configuration) for proxy testing commands and troubleshooting.