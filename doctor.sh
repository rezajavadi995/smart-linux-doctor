#!/usr/bin/env bash
set -e

# ==========================================
# Smart Linux Doctor - Advanced AI Analysis
# ==========================================

LOG_DIR="$(dirname "$0")/logs"
LOG_FILE="$LOG_DIR/actions.log"
mkdir -p "$LOG_DIR"

AUTO_MODE=false
JSON_MODE=false

# Parse args
for arg in "$@"; do
  case "$arg" in
    --auto) AUTO_MODE=true ;;
    --json) JSON_MODE=true ;;
  esac
done

# Logging function
log() {
  echo "[$(date '+%F %T')] $1" >> "$LOG_FILE"
}

# Detect OS
detect_os() {
  if [ -n "$TERMUX_VERSION" ]; then
    echo "termux"
  elif [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  else
    echo "unknown"
  fi
}

# Gather system info
system_info() {
  CPU_MODEL=$(lscpu 2>/dev/null | grep "Model name" | cut -d: -f2 | xargs || echo "Unknown CPU")
  CORES=$(nproc 2>/dev/null || echo 1)
  MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}' 2>/dev/null || echo 0)
  MEM_USED=$(free -m | awk '/Mem:/ {print $3}' 2>/dev/null || echo 0)
  SWAP_TOTAL=$(free -m | awk '/Swap:/ {print $2}' 2>/dev/null || echo 0)
  DISK_USED=$(df -h / | awk 'NR==2 {print $3}' 2>/dev/null || echo "N/A")
  DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}' 2>/dev/null || echo "N/A")
}

# Load averages
load_average() {
  if [ -r /proc/loadavg ]; then
    LOAD_1=$(awk '{print $1}' /proc/loadavg)
    LOAD_5=$(awk '{print $2}' /proc/loadavg)
    LOAD_15=$(awk '{print $3}' /proc/loadavg)
  else
    LOADS=$(uptime | awk -F'load average: ' '{print $2}')
    LOAD_1=$(echo $LOADS | cut -d, -f1)
    LOAD_5=$(echo $LOADS | cut -d, -f2)
    LOAD_15=$(echo $LOADS | cut -d, -f3)
  fi
}

# Top memory-consuming processes
top_ram_processes() {
  echo ""
  ps aux --sort=-%mem 2>/dev/null | head -n 6 || echo "Cannot list processes"
}

# Duplicate files
duplicate_files() {
  if command -v fdupes >/dev/null; then
    fdupes -r "$HOME"
  else
    echo "fdupes not installed"
  fi
}

# Unused packages
unused_packages() {
  if command -v apt >/dev/null; then
    apt list --installed 2>/dev/null | grep auto || true
  else
    echo "package manager not supported"
  fi
}

# Swap advice
swap_advice() {
  if [ "$SWAP_TOTAL" -eq 0 ] && [ "$MEM_TOTAL" -le 4096 ]; then
    echo "⚠️ No swap detected with low RAM"
    echo "👉 Suggested: create 2G–4G swap file"
  else
    echo "✔ Swap configuration looks acceptable"
  fi
}

# Generate JSON for Python analyzer
generate_json() {
  SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')
  cat <<EOF
{
  "cpu_cores": $CORES,
  "load_1": $(echo $LOAD_1 | awk '{printf "%f",$1}'),
  "load_5": $(echo $LOAD_5 | awk '{printf "%f",$1}'),
  "load_15": $(echo $LOAD_15 | awk '{printf "%f",$1}'),
  "mem_total": $MEM_TOTAL,
  "mem_used": $MEM_USED,
  "swap_total": $SWAP_TOTAL,
  "swap_used": $SWAP_USED
}
EOF
}

# Basic AI explanation
ai_explanation() {
  echo "🧠 AI System Analysis:"
  if [[ "$LOAD_1" != "N/A" ]]; then
    awk "BEGIN {exit !($LOAD_1 > $CORES)}" && echo "- High CPU load relative to cores"
  fi
  if [ "$MEM_USED" -gt $((MEM_TOTAL * 80 / 100)) ]; then
    echo "- RAM usage above 80%"
  fi
  if [ "$SWAP_TOTAL" -gt 0 ]; then
    SWAP_USED=$(free -m | awk '/Swap:/ {print $3}' 2>/dev/null || echo 0)
    if [ "$SWAP_USED" -gt 0 ]; then
      echo "- Active swap usage indicates memory pressure"
    fi
  fi
  echo "- Check top memory-consuming processes"
}

# JSON output
json_output() {
  cat <<EOF
{
  "os": "$(detect_os)",
  "cpu": "$CPU_MODEL",
  "cores": $CORES,
  "memory_mb": {
    "total": $MEM_TOTAL,
    "used": $MEM_USED
  },
  "swap_mb": $SWAP_TOTAL,
  "disk": {
    "used": "$DISK_USED",
    "total": "$DISK_TOTAL"
  },
  "load_average": {
    "1m": "$LOAD_1",
    "5m": "$LOAD_5",
    "15m": "$LOAD_15"
  }
}
EOF
}

# Install Python and dependencies
install_python() {
  OS=$(detect_os)
  SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" &>/dev/null && pwd)"
  ANALYZER="$SCRIPT_DIR/analyzer.py"

  echo "📦 Installing Python 3..."

  case "$OS" in
    ubuntu|debian|kali)
      if ! command -v sudo >/dev/null; then
        echo "❌ sudo not available. Please install Python manually."
        return
      fi
      sudo apt update
      sudo apt install -y python3 python3-pip
      ;;
    termux)
      pkg install -y python
      ;;
    *)
      echo "❌ Unsupported system. Please install Python manually."
      return
      ;;
  esac

  if command -v python3 >/dev/null && [ -f "$ANALYZER" ]; then
    echo "✅ Python installed successfully"
    generate_json | python3 "$ANALYZER"
  else
    echo "ℹ️ Python not available or analyzer.py missing. Skipping advanced AI analysis."
  fi
}

# Run Python AI analyzer
run_python_analysis() {
  SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" &>/dev/null && pwd)"
  ANALYZER="$SCRIPT_DIR/analyzer.py"
  if command -v python3 >/dev/null && [ -f "$ANALYZER" ]; then
    generate_json | python3 "$ANALYZER"
    return
  fi

  if $AUTO_MODE; then
    echo "ℹ️ Python or analyzer.py missing. Skipping advanced AI analysis."
    return
  fi

  echo ""
  echo "⚠️ Python 3 is not installed or analyzer.py missing."
  echo "Advanced AI analysis requires Python 3 and analyzer.py."
  echo ""
  echo "1) Install Python 3"
  echo "2) Skip AI analysis"
  read -p "Choose [1/2]: " PY_CHOICE

  case "$PY_CHOICE" in
    1)
      install_python
      ;;
    *)
      echo "ℹ️ Skipping AI analysis."
      ;;
  esac
}

# Run full analysis
run_all() {
  system_info
  load_average

  if $JSON_MODE; then
    json_output
    exit 0
  fi

  echo "🖥 OS: $(detect_os)"
  echo "🧠 CPU: $CPU_MODEL ($CORES cores)"
  echo "💾 RAM: $MEM_USED / $MEM_TOTAL MB"
  echo "🔁 Swap: $SWAP_TOTAL MB"
  echo "💽 Disk: $DISK_USED / $DISK_TOTAL"
  echo "📈 Load: $LOAD_1 $LOAD_5 $LOAD_15"
  echo ""

  ai_explanation
  swap_advice
  echo ""
  echo "🔥 Top RAM Consumers:"
  top_ram_processes
  echo ""
  run_python_analysis
}

# Main menu
menu() {
  while true; do
    clear
    echo "🩺 Smart Linux Doctor"
    echo "OS: $(detect_os)"
    echo ""
    echo "1) Full System Analysis"
    echo "2) Duplicate Files"
    echo "3) Unused Packages"
    echo "0) Exit"
    echo ""
    read -p "Choose: " CH

    case $CH in
      1) run_all ;;
      2) duplicate_files ;;
      3) unused_packages ;;
      0) exit 0 ;;
      *) echo "Invalid choice" ;;
    esac

    echo ""
    read -p "Press Enter to continue..."
  done
}

if $AUTO_MODE; then
  run_all
else
  menu
fi
