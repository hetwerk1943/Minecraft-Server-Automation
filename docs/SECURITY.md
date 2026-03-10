# Security

Security guidance for operators and contributors.

## Secrets management

### Discord webhook URLs

Discord webhook URLs are sensitive credentials. They must **never** be:

- Committed to source control (`.env`, script files, config files).
- Printed to logs in full.
- Shared in issue trackers or pull-request comments.

The monitoring scripts accept `-DiscordWebhookUrl` as a parameter.  
Pass the URL at runtime via an environment variable or secrets manager:

```powershell
# Good – read from environment variable at runtime
$webhookUrl = $env:DISCORD_WEBHOOK_URL
.\scripts\ServerMonitoring.ps1 -ServerPath $path -DiscordWebhookUrl $webhookUrl
```

Webhook URLs in log output are **automatically redacted** – only the first 30 characters
followed by `...` are written to log files.  Never log the full URL.

### Other secrets

- Do not hard-code API keys, passwords, or tokens in any `.ps1` file.
- Use environment variables or a secrets manager (e.g., Windows Credential Manager,
  HashiCorp Vault, GitHub Actions secrets).

## Path safety

All module functions call `Assert-PathSafe` before performing any file operations.
This prevents accidental operations on root paths (`/`, `C:\`, UNC roots) that could
destroy the host system.

## Input validation

- Parameters with `[ValidateRange]` prevent out-of-bound values (ports, memory sizes).
- Parameters with `[ValidateSet]` restrict choices to known-good values.
- `Set-StrictMode -Version Latest` is set in all Public module functions to catch typos
  and uninitialized variables at runtime.

## Process detection

Server monitoring does **not** rely on matching the `java` process's executable path against
`ServerPath`, which is fragile and can return false positives from other Java applications.
Instead, `Get-ServerHealthCheck` uses the following heuristics:

1. TCP port connectivity probe.
2. Log freshness check.

## Network exposure

- The default server port is **25565** (TCP). Firewall rules should restrict access to
  trusted IP ranges when possible.
- The monitoring scripts only make outbound HTTP(S) calls to Discord webhooks.  
  No inbound ports are opened by these scripts.

## EULA compliance

`Install-MinecraftServer` writes `eula=true` to `eula.txt`.  
By running this script you agree to the [Minecraft EULA](https://www.minecraft.net/en-us/eula).

## Monetization compliance

Review the [Minecraft Commercial Usage Guidelines](https://www.minecraft.net/en-us/usage-guidelines)
before offering any paid features.  The included `MonetizationSetup.ps1` is a template —
operators are responsible for ensuring compliance with Mojang's guidelines, local payment
regulations, GDPR/privacy laws, and consumer protection rules.

## Security disclosure

To report a security vulnerability, please open a **private security advisory** on the
GitHub repository rather than a public issue.  Do not disclose vulnerability details
publicly until a fix has been released.

## Disclaimer

These scripts are provided as-is.  The authors do **not** claim that use of these scripts
provides absolute security. Operators are responsible for hardening their own environments.
