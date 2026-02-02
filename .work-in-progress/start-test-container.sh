#!/usr/bin/env bash
# Start a fresh OpenClaw test container for manual testing
# The container will remain running so you can interact with it

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

CONTAINER_NAME="openclaw-test-$(date +%s)"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Starting Fresh OpenClaw Test Container                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Build the image
echo "Building Docker image..."
docker build -f Dockerfile.interactive -t openclaw-interactive:latest . > /dev/null 2>&1

echo "✅ Image built successfully"
echo ""

# Start container in detached mode
echo "Starting container: $CONTAINER_NAME"
docker run -d --name "$CONTAINER_NAME" openclaw-interactive:latest sleep infinity > /dev/null

echo "✅ Container started"
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Container Ready for Testing                               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Container: $CONTAINER_NAME"
echo ""
echo "📍 To enter the container:"
echo "   docker exec -it $CONTAINER_NAME bash"
echo ""
echo "📍 Once inside, you can:"
echo "   cd ~/openclaw-config/bootstrap"
echo "   ./bootstrap.sh --interactive     # Interactive installation"
echo "   ./bootstrap.sh --list-modules    # See available modules"
echo "   ./bootstrap.sh --help            # See all options"
echo ""
echo "📍 To stop the container when done:"
echo "   docker stop $CONTAINER_NAME"
echo "   docker rm $CONTAINER_NAME"
echo ""
echo "📍 Quick test command:"
echo "   docker exec -it $CONTAINER_NAME bash -c 'cd ~/openclaw-config/bootstrap && ./bootstrap.sh --non-interactive --only system-deps,python'"
echo ""
