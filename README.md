# 🩺 Smart Linux Doctor

**Smart Linux Doctor** is a safe, intelligent, and user-friendly system diagnostic and optimization assistant for Linux-based environments.

It analyzes your system, explains *why* it may be slow, detects real issues, and provides **actionable, non-destructive recommendations** — without putting your system at risk.

Designed to work seamlessly on:

- ✅ Ubuntu / Debian
- ✅ Kali Linux
- ✅ Servers (non-interactive mode)
- ✅ Termux (Android)

---

## ✨ Features

- 🧠 **AI-powered system explanation**
  - Explains *why* your system is slow (CPU, RAM, swap, load)
- 📈 **Load Average Analysis**
  - Interprets system load relative to CPU cores
- 🔁 **Smart Swap Advice**
  - Detects memory pressure and suggests safe swap strategies
- 💾 **Full System Information**
  - CPU, RAM, swap, disk, storage usage
- 🔥 **Top Resource-Hog Processes**
  - Identifies processes consuming excessive RAM
- 🗂 **Duplicate File Detection**
  - Lists duplicate files with full paths (no auto-delete)
- 📦 **Unused Package Detection**
  - Finds auto-installed, unused packages (APT-based systems)
- 📊 **JSON Output Mode**
  - Ideal for servers, monitoring, logging, automation
- 🖥 **Interactive Menu Mode**
  - Clean, guided, and user-friendly
- 🚀 **Non-Interactive Server Mode**
  - Fully automated diagnostics
- 🔒 **100% Safe by Design**
  - No auto-delete
  - No forced system changes
  - No upgrades or risky operations

---

## 📦 One-Line Installation (Copy & Paste)

Works on **all supported devices**:

```bash
curl -fsSL https://raw.githubusercontent.com/rezajavadi995/smart-linux-doctor/main/install.sh | bash
```

---
## After installation, the tool will be located at:
### ~/.smart-linux-doctor/doctor.sh


---
# ▶️ Usage Shortcut Command

## 🧭 Interactive Mode (Recommended for desktops):

```
doctor
```
**Provides a full menu-driven interface with explanations and guidance.**


---
## 🤖 Non-Interactive Mode (Servers / SSH):
```
doctor --auto
```
**Runs a full system analysis automatically.**


---
## 📊 JSON Output (Monitoring / Automation):
```
doctor --auto --json
```
**Outputs all system information in JSON format for automation, monitoring, or logging.**

---

## 🛡 Safety Principles

**Smart Linux Doctor** will never:

- ❌ Delete files automatically  
- ❌ Kill running processes  
- ❌ Modify swap or system configurations  
- ❌ Run system upgrades or risky commands  

All actions are **analysis-only**, with clear explanations and full user control.

