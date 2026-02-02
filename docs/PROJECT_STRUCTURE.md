# OpenClaw Project Structure

## Directory Organization

```
openclaw-config/
├── bootstrap/              # Bootstrap installation system
│   ├── lib/               # Shared libraries
│   ├── modules/           # Installation modules
│   ├── scripts/           # Utility scripts
│   └── tests/             # Test suite
├── deployment-tools/      # Deployment configurations
│   ├── mcp/               # MCP server configurations
│   └── config/            # Environment templates
├── docs/                  # Documentation
│   ├── guides/            # User guides
│   ├── development/       # Development docs
│   └── INSTALLATION.md    # Main installation guide
├── reports/               # Analysis reports
├── .work-in-progress/     # Development files (not committed)
│   └── testing/           # Test scripts
├── README.md              # Main project README
└── START_HERE.md          # Quick start guide
```

## Documentation Organization

### User-Facing Documentation
- **README.md** - Main project overview
- **START_HERE.md** - Quick start guide
- **docs/INSTALLATION.md** - Detailed installation instructions
- **docs/guides/** - Feature-specific guides
  - DEPLOYMENT_SUMMARY.md
  - DEV_TOOLS_GUIDE.md
  - GITHUB_SETUP.md
  - MIGRATION.md
  - OPENCLAW_DOCUMENTATION.md
  - SECURITY_GUIDE.md
  - SECURITY.md

### Development Documentation
- **docs/development/** - Internal development docs
  - DOCKER_TEST_FIXES.md
  - DOCKER_TEST_INSTRUCTIONS.md
  - HUMAN_TEST_GUIDE.md
  - IMPROVEMENTS_SUMMARY.md
  - INSTALLATION_IMPROVEMENTS.md

## Work-in-Progress Directory

The `.work-in-progress/` directory is excluded from git commits and contains:
- Experimental code
- Testing scripts
- Development containers
- Temporary debugging files

This keeps the project root clean while providing a dedicated space for development work.

## Git Workflow

All development files stay in `.work-in-progress/` until ready for commit.
Only production-ready code and documentation should be in the main directories.
