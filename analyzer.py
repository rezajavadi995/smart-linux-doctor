#!/usr/bin/env python3
import json
import sys

data = json.load(sys.stdin)

issues = []
advice = []

# CPU load analysis
if data["load_1"] > data["cpu_cores"]:
    issues.append("High CPU load relative to CPU cores")
    advice.append("Check CPU-intensive processes")

# Memory pressure
mem_percent = (data["mem_used"] / data["mem_total"]) * 100
if mem_percent > 80:
    issues.append("High RAM usage detected")
    advice.append("Close heavy apps or consider adding swap")

# Swap advice
if data["swap_total"] == 0 and data["mem_total"] <= 4096:
    issues.append("No swap detected on low-memory system")
    advice.append("Create a 2–4GB swap file")

print("🧠 Advanced AI Analysis:\n")

if not issues:
    print("✔ No critical performance issues detected")
else:
    for i in issues:
        print(f"- ⚠️ {i}")

print("\n💡 Recommendations:\n")
for a in advice:
    print(f"- ✅ {a}")
