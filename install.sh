#!/usr/bin/env bash
set -e

echo "🩺 Smart Linux Doctor Installer"

INSTALL_DIR="$HOME/.smart-linux-doctor"

if [ -d "$INSTALL_DIR" ]; then
  echo "⚠️ Already installed at $INSTALL_DIR"
  exit 0
fi

git clone https://github.com/YOUR_USERNAME/smart-linux-doctor.git "$INSTALL_DIR"

chmod +x "$INSTALL_DIR/doctor.sh"

echo ""
echo "✅ Installation complete"
echo "Run:"
echo "  $INSTALL_DIR/doctor.sh"
echo "Non-interactive (server):"
echo "  $INSTALL_DIR/doctor.sh --auto --json"
