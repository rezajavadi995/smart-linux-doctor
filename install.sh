#!/usr/bin/env bash
set -e

echo "🩺 Smart Linux Doctor Installer"

INSTALL_DIR="$HOME/.smart-linux-doctor"

if [ -d "$INSTALL_DIR" ]; then
  echo "⚠️ Already installed at $INSTALL_DIR"
  exit 0
fi

if ! command -v git >/dev/null; then
  echo "❌ Git is not installed. Please install git first."
  exit 1
fi

# Clone the repository (public repo)
git clone https://github.com/rezajavadi995/smart-linux-doctor.git "$INSTALL_DIR"

chmod +x "$INSTALL_DIR/doctor.sh"

# Detect Termux
if [ -n "$PREFIX" ]; then
  BIN_DIR="$PREFIX/bin"
else
  BIN_DIR="$HOME/.local/bin"
fi

mkdir -p "$BIN_DIR"
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
echo "✅ Installation complete"
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
