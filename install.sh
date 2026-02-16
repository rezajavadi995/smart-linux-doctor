#!/usr/bin/env bash
set -e

echo "🩺 Smart Linux Doctor Installer"

INSTALL_DIR="$HOME/.smart-linux-doctor"

# Detect Termux
if [ -n "$PREFIX" ]; then
  BIN_DIR="$PREFIX/bin"
else
  BIN_DIR="$HOME/.local/bin"
fi

mkdir -p "$BIN_DIR"

if [ -d "$INSTALL_DIR" ]; then
  echo "⚠️ Smart Linux Doctor already installed at $INSTALL_DIR"
  echo "🔄 Updating to latest version..."
  cd "$INSTALL_DIR"
  git reset --hard
  git pull origin main || {
    echo "❌ Failed to update. Check your network or git configuration."
    exit 1
  }
else
  if ! command -v git >/dev/null; then
    echo "❌ Git is not installed. Please install git first."
    exit 1
  fi

  echo "Cloning Smart Linux Doctor..."
  git clone https://github.com/rezajavadi995/smart-linux-doctor.git "$INSTALL_DIR" || {
    echo "❌ Clone failed. Check your network."
    exit 1
  }
fi

# Make scripts executable
chmod +x "$INSTALL_DIR/doctor.sh"
chmod +x "$INSTALL_DIR/analyzer.py" 2>/dev/null || true

# Create/update symlink
ln -sf "$INSTALL_DIR/doctor.sh" "$BIN_DIR/doctor"

# Check PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo ""
  echo "⚠️ Notice: $BIN_DIR is not in your PATH."
  echo "To run 'doctor' from anywhere, add this line to your shell config (e.g., ~/.bashrc or ~/.zshrc):"
  echo ""
  echo "  export PATH=\"\$PATH:$BIN_DIR\""
  echo ""
  echo "Then restart your terminal or run 'source ~/.bashrc' (or 'source ~/.zshrc')"
fi

echo ""
echo "✅ Smart Linux Doctor is installed and up-to-date"
echo ""
echo "Run full system analysis interactively:"
echo "  doctor"
echo ""
echo "Run in non-interactive server mode:"
echo "  doctor --auto"
echo ""
echo "Run JSON output (monitoring/automation):"
echo "  doctor --auto --json"
echo ""
echo "💡 Note: If 'doctor' command doesn't work, make sure $BIN_DIR is in your PATH"
