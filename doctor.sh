#!/usr/bin/env bash

LOG_DIR="$(dirname "$0")/logs"
LOG_FILE="$LOG_DIR/actions.log"
mkdir -p "$LOG_DIR"

AUTO_MODE=false
JSON_MODE=false

for arg in "$@"; do
  case "$arg" in
    --auto) AUTO_MODE=true ;;
    --json) JSON_MODE=true ;;
  esac
done

log() {
  echo "[$(date '+%F %T')] $1" >> "$LOG_FILE"
}

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

system_info() {
  CPU_MODEL=$(lscpu | grep "Model name" | cut -d: -f2 | xargs)
  CORES=$(nproc)
  MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
  MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
  SWAP_TOTAL=$(free -m | awk '/Swap:/ {print $2}')
  DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
  DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
}

load_average() {
  LOAD_1=$(awk '{print $1}' /proc/loadavg)
  LOAD_5=$(awk '{print $2}' /proc/loadavg)
  LOAD_15=$(awk '{print $3}' /proc/loadavg)
}

top_ram_processes() {
  ps aux --sort=-%mem | head -n 6
}

duplicate_files() {
  if command -v fdupes >/dev/null; then
    fdupes -r "$HOME"
  else
    echo "fdupes not installed"
  fi
}

unused_packages() {
  if command -v apt >/dev/null; then
    apt list --installed 2>/dev/null | grep auto || true
  else
    echo "package manager not supported"
  fi
}

swap_advice() {
  if [ "$SWAP_TOTAL" -eq 0 ] && [ "$MEM_TOTAL" -le 4096 ]; then
    echo "⚠️ No swap detected with low RAM"
    echo "👉 Suggested: create 2G–4G swap file"
  else
    echo "✔ Swap configuration looks acceptable"
  fi
}


generate_json() {
  cat <<EOF
{
  "cpu_cores": $CORES,
  "load_1": $LOAD_1,
  "load_5": $LOAD_5,
  "load_15": $LOAD_15,
  "mem_total": $MEM_TOTAL,
  "mem_used": $MEM_USED,
  "swap_total": $SWAP_TOTAL,
  "swap_used": $(free -m | awk '/Swap:/ {print $3}')
}
EOF
}





ai_explanation() {
  echo "🧠 AI System Analysis:"

  if awk "BEGIN {exit !($LOAD_1 > $CORES)}"; then
    echo "- High CPU load relative to cores"
  fi

  if [ "$MEM_USED" -gt $((MEM_TOTAL * 80 / 100)) ]; then
    echo "- RAM usage above 80%"
  fi

  if [ "$SWAP_TOTAL" -gt 0 ]; then
    SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')
    if [ "$SWAP_USED" -gt 0 ]; then
      echo "- Active swap usage indicates memory pressure"
    fi
  fi

  echo "- Check top memory-consuming processes"
}

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

#
install_python() {
  OS=$(detect_os)

  echo "📦 Installing Python 3..."

  case "$OS" in
    ubuntu|debian|kali)
      if ! command -v sudo >/dev/null; then
        echo "❌ sudo not available. Please install Python manually."
        return
      fi
      sudo apt update
      sudo apt install -y python3
      ;;
    termux)
      pkg install -y python
      ;;
    *)
      echo "❌ Unsupported system. Please install Python manually."
      return
      ;;
  esac

  if command -v python3 >/dev/null; then
    echo "✅ Python installed successfully"
    generate_json | python3 "$(dirname "$0")/analyzer.py"
  else
    echo "❌ Python installation failed or cancelled"
  fi
}
#
run_python_analysis() {
  if command -v python3 >/dev/null; then
    generate_json | python3 "$(dirname "$0")/analyzer.py"
    return
  fi

  # اگر حالت اتوماتیک یا سرور است → سؤال نپرس
  if $AUTO_MODE; then
    echo "ℹ️ Python not available. Skipping advanced AI analysis."
    return
  fi

  echo ""
  echo "⚠️ Python is not installed."
  echo "Advanced AI analysis requires Python 3."
  echo ""
  echo "1) Install Python"
  echo "2) Skip AI analysis"
  echo ""
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
  echo ""
  swap_advice
  echo ""
  echo "🔥 Top RAM Consumers:"
  top_ram_processes
  echo ""
  run_python_analysis
}

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
