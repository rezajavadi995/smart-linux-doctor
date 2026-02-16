#!/usr/bin/env python3
import json
import sys
import psutil
import os

data = json.load(sys.stdin)

issues = []
advice = []

# Convert string load to float if needed
load_1 = float(data.get("load_1", 0))
load_5 = float(data.get("load_5", 0))
load_15 = float(data.get("load_15", 0))
cores = int(data.get("cpu_cores", 1))
mem_total = int(data.get("mem_total", 0))
mem_used = int(data.get("mem_used", 0))
swap_total = int(data.get("swap_total", 0))
swap_used = int(data.get("swap_used", 0))

print("🧠 Advanced AI Analysis:\n")

# CPU load
if load_1 > cores:
    issues.append("High CPU load relative to CPU cores")
    advice.append("Investigate CPU-intensive processes or threads")

# RAM pressure
mem_percent = (mem_used / mem_total) * 100 if mem_total > 0 else 0
if mem_percent > 80:
    issues.append("High RAM usage detected")
    advice.append("Consider closing heavy apps or adding swap")

# Swap advice
if swap_total == 0 and mem_total <= 4096:
    issues.append("No swap detected on low-memory system")
    advice.append("Create a 2–4GB swap file")

if swap_used > 0 and mem_percent > 75:
    issues.append("System using swap with high RAM usage")
    advice.append("Memory pressure is high; consider reducing load")

# IO load detection (simple)
disk_io = psutil.disk_io_counters()
read_mb = disk_io.read_bytes / (1024*1024)
write_mb = disk_io.write_bytes / (1024*1024)
if read_mb + write_mb > 1000:  # arbitrary high IO
    issues.append("High disk IO detected")
    advice.append("Check heavy read/write processes")

# Network activity detection
net_io = psutil.net_io_counters()
if net_io.bytes_sent + net_io.bytes_recv > 1024*1024*1024:
    issues.append("High network usage detected")
    advice.append("Check network-intensive apps or downloads")

# Output issues
if not issues:
    print("✔ No critical performance issues detected")
else:
    for i in issues:
        print(f"- ⚠️ {i}")

# Recommendations
print("\n💡 Recommendations:")
for a in advice:
    print(f"- ✅ {a}")

# Optional: top CPU consumers
print("\n🔥 Top CPU-consuming processes:")
try:
    procs = [(p.pid, p.info['name'], p.info['cpu_percent']) for p in psutil.process_iter(['name','cpu_percent'])]
    procs.sort(key=lambda x: x[2], reverse=True)
    for pid, name, cpu in procs[:5]:
        print(f"PID {pid} | {name} | CPU% {cpu}")
except Exception as e:
    print("Cannot fetch top CPU processes:", e)

# Optional: top RAM consumers
print("\n🔥 Top RAM-consuming processes:")
try:
    procs = [(p.pid, p.info['name'], p.info['memory_info'].rss/1024/1024) for p in psutil.process_iter(['name','memory_info'])]
    procs.sort(key=lambda x: x[2], reverse=True)
    for pid, name, mem in procs[:5]:
        print(f"PID {pid} | {name} | RAM {mem:.2f} MB")
except Exception as e:
    print("Cannot fetch top RAM processes:", e)
