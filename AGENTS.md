# AGENTS.md - AI Agent Guidelines for openclaw-config

This document provides context and guidelines for AI coding agents working in this repository.

## Project Overview

OpenClaw VM Configuration - Automated configuration and deployment system for OpenClaw VMs with comprehensive tooling for AI development, cloud deployment, file sharing, and personal productivity.

**Primary Languages**: Bash (bootstrap system), JavaScript/Node.js (MCP servers)
**Configuration**: YAML (manifest, packages, checksums)

## Build, Lint, and Test Commands

### Bootstrap System Validation

```bash
# Verify file structure (quick check)
./bootstrap/verify.sh

# Validate installation
./bootstrap/bootstrap.sh --validate

# Run diagnostics
./bootstrap/bootstrap.sh --doctor

# Preview changes without installing
./bootstrap/bootstrap.sh --dry-run

# Install specific modules only
./bootstrap/bootstrap.sh --only system-deps,python,nodejs
```

### Docker Integration Tests

```bash
# Run full Docker test suite
./test-docker-install.sh

# The test suite builds a Docker image and tests:
# - Minimal installation (system-deps only)
# - Foundation modules (python, nodejs)
# - Security vulnerability checks (no curl|bash patterns)
```

### Module-Level Testing

```bash
# Run a specific module directly
cd bootstrap/modules
bash 01-system-deps.sh check      # Check if installed
bash 01-system-deps.sh install    # Install module
bash 01-system-deps.sh validate   # Validate installation
bash 01-system-deps.sh rollback   # Rollback (if supported)
```

### MCP Server Development

```bash
cd bootstrap/config/mcp-servers
npm install                       # Install dependencies
node implementations/todoist-mcp.js  # Run server directly (for testing)
```

### Linting

No automated linters configured at repository level. Use:
- `shellcheck` for Bash scripts
- Standard JavaScript conventions for MCP servers

## Code Style Guidelines

### Bash Scripts

#### File Header
```bash
#!/usr/bin/env bash

# Module: Module Name
# Description of what this module does

MODULE_NAME="module-name"
MODULE_VERSION="1.0.0"
MODULE_DESCRIPTION="Module description"
MODULE_DEPS=()  # Array of module dependencies
```

#### Strict Mode
Always start scripts with:
```bash
set -euo pipefail
```

#### Variable Declarations
```bash
# Use local for function-scoped variables
local variable="value"
local -a array_var=("item1" "item2")

# Quote all variable expansions
echo "$variable"
for item in "${array_var[@]}"; do
```

#### Sourcing Libraries
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Use shellcheck directive
# shellcheck source=../lib/logger.sh
source "$LIB_DIR/logger.sh"
```

#### Module Function Pattern
Every module must implement:
```bash
check_installed()  # Return 0 if already installed
install()          # Perform installation
validate()         # Verify installation succeeded
rollback()         # Undo installation (optional)
```

#### Logging
Use the logger.sh utilities:
```bash
log_info "Informational message"
log_success "Success message"
log_error "Error message"
log_warn "Warning message"
log_progress "Progress message"
log_debug "Debug message (verbose mode only)"
log_section "Section Header"
```

#### Validation Functions
Use validation.sh utilities for input sanitization:
```bash
validate_module_name "$module"     # Alphanumeric, hyphens, underscores only
validate_url "$url"                # HTTPS only, no credentials in URL
validate_path "$path"              # No directory traversal (..)
validate_env_var_name "$name"      # Valid env var format
validate_command "$cmd"            # Command exists in PATH
validate_package "$package"        # APT package installed
```

### JavaScript (MCP Servers)

#### File Header
```javascript
#!/usr/bin/env node

/**
 * Service Name MCP Server
 * Description of what this server provides
 *
 * Tools:
 * - toolName: Tool description
 */
```

#### Module Imports
```javascript
const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const { CallToolRequestSchema, ListToolsRequestSchema } = require('@modelcontextprotocol/sdk/types.js');
```

## Naming Conventions

| Category | Bash | JavaScript |
|----------|------|------------|
| Files (modules) | `NN-module-name.sh` | `service-name-mcp.js` |
| Constants | `UPPER_SNAKE_CASE` | `UPPER_SNAKE_CASE` |
| Variables | `lower_snake_case` (local) | `camelCase` |
| Functions | `snake_case` | `camelCase` |

## Error Handling

### Bash
- Use return codes (0 = success, non-zero = failure)
- Track overall success with boolean variables
- Always log errors before returning

### JavaScript
- Use try/catch with async/await
- Return `{ isError: true }` in MCP responses for failures
- Log to stderr with `console.error()`

## Security Considerations

- Never hardcode credentials in source files
- Use environment variables for API tokens (`.env` files are gitignored)
- logger.sh automatically sanitizes secrets from log output
- Use validation.sh functions for all user inputs
- Use checksums.yaml for SHA256 download verification

## Directory Structure

```
openclaw-config/
├── bootstrap/                 # Bootstrap installation system
│   ├── bootstrap.sh           # Main orchestrator
│   ├── verify.sh              # Quick verification
│   ├── manifest.yaml          # Module versions
│   ├── checksums.yaml         # Download verification
│   ├── modules/               # Installation modules (01-15)
│   ├── lib/                   # Shared utilities (logger, validation, etc.)
│   └── templates/             # Template files
├── deployment-tools/          # Deployment configuration
│   └── mcp/implementations/   # Custom MCP servers (JS)
└── docs/                      # Project documentation
```

## Common Patterns

### Adding a New Module
1. Create `bootstrap/modules/NN-module-name.sh`
2. Implement: `check_installed()`, `install()`, `validate()`, `rollback()`
3. Add to `manifest.yaml` and `checksums.yaml` (if downloading files)
4. Test: `./bootstrap.sh --only module-name --validate`

### Adding a New MCP Server
1. Create `deployment-tools/mcp/implementations/service-mcp.js`
2. Follow the class pattern with `setupHandlers()` and `setupErrorHandling()`
3. Add to `mcp-servers-extended.json` or `mcp-servers-full-stack.json`
4. Add dependencies to `bootstrap/config/mcp-servers/package.json`
