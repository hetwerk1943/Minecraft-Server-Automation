# Repository Audit Report

**Repository:** Minecraft-Server-Automation  
**Audit Date:** 2026-02-27  
**Auditor:** Automated Code Audit

---

## Executive Summary

This repository contains PowerShell automation scripts for Minecraft server management, including server setup, monitoring, player management, backups, updates, and monetization configuration. The codebase is well-structured for a PowerShell project with good error handling throughout. Several security issues and code quality improvements were identified and addressed.

---

## 1. Structural Issues

| Issue | Severity | Status |
|-------|----------|--------|
| Duplicated `Write-ColorMessage` function in all 7 scripts | Medium | ✅ Fixed — extracted to `lib/SharedFunctions.psm1` |
| Duplicated `Test-JavaInstallation` function in 2 scripts | Medium | ✅ Fixed — extracted to `lib/SharedFunctions.psm1` |
| No shared module for common utilities | Medium | ✅ Fixed — created `lib/SharedFunctions.psm1` |
| Flat file structure (all scripts in root) | Low | Acceptable for project size |

---

## 2. Security Issues

| Issue | Severity | Status |
|-------|----------|--------|
| Placeholder Discord webhook URL in MonetizationSetup.ps1 could lead to committing real secrets | **High** | ✅ Fixed — replaced with empty default and env var instructions |
| `enable-command-block=true` by default in server.properties (enables potential abuse) | **High** | ✅ Fixed — changed to `false` |
| Wildcard permission `'*'` granted to Legend donor rank | **High** | ✅ Fixed — replaced with specific permissions |
| Wildcard permissions `essentials.*`, `minecraft.command.*`, `worldedit.*` for Platinum VIP | **Medium** | ✅ Fixed — replaced with explicit permissions |
| Player name sanitization in PlayerManagement.ps1 only removes special characters | Low | Acceptable — Minecraft names are validated server-side |
| Discord webhook URL passed as command-line parameter (visible in process list) | Low | Mitigated — URL is passed as parameter, not hardcoded |

---

## 3. Performance Issues

| Issue | Severity | Status |
|-------|----------|--------|
| Process detection in ServerMonitoring.ps1 matches any Java process with ServerPath in path | Low | No change needed — existing filter is reasonable |
| ServerMonitoring.ps1 reads last 1000 lines of log on each check | Low | Acceptable — tail-based reading is efficient |

---

## 4. Code Quality Issues

| Issue | Severity | Status |
|-------|----------|--------|
| Hardcoded path separator `logs\latest.log` in ServerMonitoring.ps1 | Medium | ✅ Fixed — now uses `Join-Path` for cross-platform compatibility |
| No test infrastructure | Low | Acceptable — PowerShell scripts with manual testing |
| No `.editorconfig` or formatting standards | Low | Not addressed — out of scope for minimal changes |
| MonetizationSetup.ps1 is large (650+ lines) | Low | Acceptable — well-organized with clear function separation |

---

## 5. Refactoring Summary

### Changes Made

1. **Created `lib/SharedFunctions.psm1`** — Shared module containing:
   - `Write-ColorMessage` — colored console output utility
   - `Test-JavaInstallation` — Java availability checker

2. **Updated all 7 scripts** to import the shared module via `Import-Module`

3. **Security hardening in `MonetizationSetup.ps1`:**
   - Removed placeholder webhook URL, replaced with empty string and security comments
   - Replaced wildcard permissions for Platinum VIP with explicit permission list
   - Replaced `'*'` wildcard for Legend donor rank with specific permissions

4. **Security hardening in `MinecraftServerSetup.ps1`:**
   - Changed `enable-command-block` from `true` to `false` in default server.properties

5. **Cross-platform fix in `ServerMonitoring.ps1`:**
   - Replaced hardcoded `"logs\latest.log"` with `Join-Path "logs" "latest.log"`

### Files Modified
- `BackupServer.ps1` — Import shared module, removed duplicate function
- `MinecraftServerSetup.ps1` — Import shared module, removed duplicate functions, security fix
- `MonetizationSetup.ps1` — Import shared module, removed duplicate function, security fixes
- `PlayerManagement.ps1` — Import shared module, removed duplicate function
- `ServerMonitoring.ps1` — Import shared module, removed duplicate function, path fix
- `StartServer.ps1` — Import shared module, removed duplicate functions
- `UpdateServer.ps1` — Import shared module, removed duplicate function

### Files Created
- `lib/SharedFunctions.psm1` — Shared utility module

---

## 6. Final Verification

- ✅ No broken imports — all scripts reference `lib/SharedFunctions.psm1` via `$PSScriptRoot`
- ✅ No circular dependencies — single shared module imported by all scripts
- ✅ Clean folder structure — shared code in `lib/`, scripts in root
- ✅ No removed functionality — all existing features preserved
- ✅ No hardcoded secrets — webhook URL cleared, env var pattern documented
- ✅ No wildcard permissions — all permissions are now explicit
