#!/usr/bin/env bash

# Package Manager Utilities
# Provides caching and optimization for package management operations

set -euo pipefail

# Cache file for apt-get update timestamp
APT_UPDATE_CACHE="/var/cache/openclaw-apt-updated"
APT_UPDATE_TTL=86400  # 24 hours in seconds

#
# Check if apt-get update is needed
#
# Returns:
#   0 if update needed, 1 if cache is fresh
#
need_apt_update() {
    # If cache file doesn't exist, update is needed
    if [[ ! -f "$APT_UPDATE_CACHE" ]]; then
        return 0
    fi

    # Check if cache is expired
    local last_update
    last_update=$(stat -c %Y "$APT_UPDATE_CACHE" 2>/dev/null || echo 0)
    local current_time
    current_time=$(date +%s)
    local age=$((current_time - last_update))

    if [[ $age -gt $APT_UPDATE_TTL ]]; then
        return 0  # Cache expired, update needed
    fi

    return 1  # Cache is fresh
}

#
# Run apt-get update with caching
#
# This function checks if apt-get update was run recently and skips it if so.
# Use force=true to bypass cache and always update.
#
# Arguments:
#   $1 - force (optional): Set to "true" to force update regardless of cache
#
# Returns:
#   0 on success, 1 on failure
#
cached_apt_update() {
    local force="${1:-false}"

    # Source logger if not already loaded
    if ! declare -f log_info &>/dev/null; then
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        # shellcheck source=./logger.sh
        source "$SCRIPT_DIR/logger.sh"
    fi

    if [[ "$force" != "true" ]] && ! need_apt_update; then
        log_info "Package lists are up to date (cached)"
        return 0
    fi

    log_progress "Updating apt package lists"

    if sudo apt-get update -qq 2>&1; then
        # Update cache timestamp
        sudo mkdir -p "$(dirname "$APT_UPDATE_CACHE")"
        sudo touch "$APT_UPDATE_CACHE"
        log_success "Package lists updated"
        return 0
    else
        log_error "Failed to update package lists"
        return 1
    fi
}

#
# Install packages with better error handling
#
# Arguments:
#   $@ - Package names to install
#
# Returns:
#   0 on success, 1 on failure
#
install_packages() {
    local -a packages=("$@")

    if [[ ${#packages[@]} -eq 0 ]]; then
        log_error "No packages specified"
        return 1
    fi

    # Source logger if not already loaded
    if ! declare -f log_info &>/dev/null; then
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        # shellcheck source=./logger.sh
        source "$SCRIPT_DIR/logger.sh"
    fi

    log_progress "Installing packages: ${packages[*]}"

    local output
    if output=$(sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${packages[@]}" 2>&1); then
        log_success "Packages installed successfully"
        return 0
    else
        log_error "Failed to install packages"

        # Show last 10 lines of error
        local error_lines
        error_lines=$(echo "$output" | tail -10)
        echo "$error_lines" >&2

        # Check for common issues
        if echo "$output" | grep -q "Unable to locate package"; then
            local missing
            missing=$(echo "$output" | grep "Unable to locate package" | sed 's/.*package //' | head -3)
            log_error "Package(s) not found in repositories: $missing"
            log_info "Try running: sudo apt-get update"
        elif echo "$output" | grep -q "dpkg was interrupted"; then
            log_error "Previous package installation was interrupted"
            log_info "Try running: sudo dpkg --configure -a"
        elif echo "$output" | grep -q "Could not get lock"; then
            log_error "Another package manager is running"
            log_info "Wait for other installations to complete or run: sudo killall apt apt-get"
        fi

        return 1
    fi
}

#
# Clear apt cache
#
clear_apt_cache() {
    if [[ -f "$APT_UPDATE_CACHE" ]]; then
        sudo rm -f "$APT_UPDATE_CACHE"
    fi
}

# Export functions
export -f need_apt_update
export -f cached_apt_update
export -f install_packages
export -f clear_apt_cache
