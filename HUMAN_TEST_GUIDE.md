# Human Testing Guide for OpenClaw Bootstrap

A fresh Docker container is ready for you to test the installation system.

## Container Information

**Container Name:** `openclaw-test-1770006720`
**Environment:** Clean Debian 12 (bookworm)
**Repository:** Pre-loaded at `~/openclaw-config`

## Quick Start

### Enter the container:
```bash
docker exec -it openclaw-test-1770006720 bash
```

You'll see a welcome screen with the repository already set up.

## Test Scenarios

### 1. Interactive Installation (Recommended for First Test)
```bash
cd ~/openclaw-config/bootstrap
./bootstrap.sh --interactive
```

**What to check:**
- ✅ Welcome screen appears
- ✅ Preset menu shows (Minimal, Developer, Full, Custom)
- ✅ Can select modules with spacebar
- ✅ Dependencies are auto-included
- ✅ Installation summary shows correct modules
- ✅ Confirmation prompt works

### 2. Quick Non-Interactive Test
```bash
cd ~/openclaw-config/bootstrap
./bootstrap.sh --non-interactive --only system-deps,python
```

**What to check:**
- ✅ System packages install
- ✅ Python virtual environment creates at `~/.local/venv/openclaw`
- ✅ Python packages install (openai, anthropic, google-generativeai)
- ✅ All validation passes
- ✅ No errors in output

### 3. List Available Modules
```bash
./bootstrap.sh --list-modules
```

**What to check:**
- ✅ Shows all 16 modules with descriptions
- ✅ Version numbers displayed

### 4. Dry Run Mode
```bash
./bootstrap.sh --dry-run --only system-deps,python,claude-cli
```

**What to check:**
- ✅ Shows what WOULD be installed
- ✅ No actual installation happens
- ✅ Can preview installation plan

### 5. Validate Existing Installation
After running a test installation:
```bash
./bootstrap.sh --validate
```

**What to check:**
- ✅ Validates all installed modules
- ✅ Shows which modules pass/fail validation

## What to Look For

### ✅ Good Signs:
- Clean, readable output with colors
- Progress bars during installation
- Clear success/failure messages
- Modules install in correct order (dependencies first)
- Working directory stays at `/home/testuser/openclaw-config/bootstrap`
- Python venv creates successfully
- All validation passes

### ❌ Warning Signs:
- Nested directory paths appearing
- Claude CLI not found after installation
- Python venv creation failing with "ensurepip not available"
- Modules installing in wrong order
- Color codes appearing as raw text (e.g., `[0;32m`)
- Validation failures

## Debug Mode

For detailed output:
```bash
./bootstrap.sh --verbose --only system-deps,python
```

This will show debug output including:
- Working directory at each step
- Command validation details
- Detailed installation progress

## Check Logs

If something goes wrong:
```bash
ls -la ~/openclaw-config/bootstrap/logs/
cat ~/openclaw-config/bootstrap/logs/bootstrap-*.log
```

## Verify Installation

After a successful installation:

### Check Python environment:
```bash
source ~/.local/venv/openclaw/bin/activate
python --version
pip list | grep -E "openai|anthropic|google"
```

### Check system packages:
```bash
which git curl python3 sqlite3
gcc --version
```

### Check virtual environment:
```bash
ls -la ~/.local/venv/openclaw/
```

## Common Issues & Solutions

### Issue: Interactive mode doesn't work
**Solution:** Make sure you're in a TTY. Run:
```bash
./bootstrap.sh --non-interactive --only system-deps,python
```

### Issue: Python venv fails
**Check:** Is `python3.11-venv` installed?
```bash
dpkg -l | grep python3.11-venv
```

### Issue: Claude CLI not found
**Check:** Is it in PATH?
```bash
find ~ -name claude 2>/dev/null
echo $PATH
```

## Cleanup

When done testing:

### Exit the container:
```bash
exit
```

### Stop and remove the container:
```bash
docker stop openclaw-test-1770006720
docker rm openclaw-test-1770006720
```

## Create a New Test Container

To start fresh:
```bash
./start-test-container.sh
```

This creates a new clean container with a unique name.

## Report Issues

If you find any issues:

1. **Capture the error:**
   ```bash
   # Inside container
   ./bootstrap.sh --verbose --only <failing-module> 2>&1 | tee error.log
   ```

2. **Check logs:**
   ```bash
   cat ~/openclaw-config/bootstrap/logs/bootstrap-*.log
   ```

3. **Note the environment:**
   - Container name
   - Which test scenario
   - Which module failed
   - Error message

4. **Exit and copy logs:**
   ```bash
   exit
   docker cp openclaw-test-1770006720:/home/testuser/openclaw-config/bootstrap/logs/bootstrap-*.log .
   ```

## Success Criteria

A successful test should show:
- ✅ All selected modules install without errors
- ✅ All validation passes
- ✅ Python packages are available in venv
- ✅ Working directory remains stable
- ✅ No nested directory paths
- ✅ Clean, readable output

Enjoy testing! 🚀
