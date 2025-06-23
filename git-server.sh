#!/bin/bash

# Git HTTP Server für ArgoCD Demo
# Usage: ./git-server.sh [port]

PORT=${1:-8000}
REPO_DIR=$(pwd)

echo "Starting Git HTTP Server for ArgoCD Demo"
echo "Repository: $REPO_DIR"
echo "Port: $PORT"
echo ""

# Git für HTTP Server konfigurieren
echo "Configuring Git for HTTP serving..."
git config http.receivepack true
git config http.uploadpack true
git update-server-info

# Prüfen ob Git Repository valid ist
if [ ! -d ".git" ]; then
    echo "Not a Git repository! Please run 'git init' first."
    exit 1
fi

# Check if we have commits
if ! git rev-parse HEAD >/dev/null 2>&1; then
    echo "No commits found. Creating initial commit..."
    git add .
    git commit -m "Initial commit for ArgoCD demo"
fi

# Server-Info aktualisieren
git update-server-info

echo "Git repository configured for HTTP serving"
echo ""
echo "ArgoCD Configuration:"
echo "   Repository URL: http://host.docker.internal:$PORT/.git"
echo "   Target Revision: HEAD"
echo "   Path: ."
echo ""
echo "Test the server:"
echo "   curl http://localhost:$PORT/info/refs?service=git-upload-pack"
echo ""

# Cleanup-Funktion für Ctrl+C
cleanup() {
    echo ""
    echo "Shutting down Git HTTP server..."
    exit 0
}
trap cleanup INT TERM

# HTTP Server starten
echo "🌐 Starting HTTP server on http://localhost:$PORT"
echo "   Press Ctrl+C to stop"
echo ""

python3 -m http.server $PORT --bind 0.0.0.0