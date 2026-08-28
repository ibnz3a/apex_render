# Changelog

All notable changes to **Apex Render** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [4.6.1] - 2026-08-24

### 🚀 Added
- Merged HyperOS 3 optimizations:
  - PowerHAL initialization (`vendor.powerhal.init 1`)
  - Power configuration (`ro.vendor.power.config 1`)
  - CPU deep sleep forcing (`cpuidle/low_power_state 1`)
  - Background location interval set to 30 minutes (`persist.sys.background_location_interval 1800`)
  - Disabled auto-retrieval (`ro.config.auto_retrieval false`)
  - Disabled night mode (`persist.vendor.night.mode 0`)
- Extended Google tamer:
  - Disabled `AnalyticsService`, `AnalyticsTaskService`
  - Disabled `AppMeasurementService`, `Feedback`

### ⚡ Improved
- **Schedutil**: Lowered `down_rate_limit_us` from 50 → **30** (smoother frequency transitions)
- **CPU Boost**: Increased `input_boost_ms` from 60 → **80** (better touch responsiveness)
- **GPU**: Reduced `idle_timer` from 10ms → **5ms** (faster GPU wake-up)
- **VM**: Adjusted `swappiness` from 60 → **50** (less swap usage, better battery)
- **VM**: Adjusted `vfs_cache_pressure` from 100 → **80** (more cache in RAM, smoother UI)

### 🐛 Fixed
- Restore all v3 properties on uninstall (night mode, powerhal, location interval, etc.)
- Improved uninstaller to re-enable disabled Google services

---

## [4.6] - 2026-08-23

### 🚀 Added
- Full micro-stutter elimination at 60Hz
- Aggressive `schedutil` tuning (`up_rate=0`, `down_rate=50`)
- Increased HWUI caches: `texture=256`, `layer=192`, `r_buffer=48`, `path=96`
- GPU `idle_timer` set to 10ms for faster response

### 🐛 Fixed
- Reduced micro-stutters during scrolling and animations
- Improved touch response latency

---

## [4.5] - 2026-08-22

### 🚀 Added
- Initial release for HyperOS 4 (sweet)
- Full system optimization (CPU, GPU, I/O, VM, Network)
- 60Hz panel lock at hardware level
- Adreno 618 full tuning (governor, freqs, bus_split, throttling)
- Network optimization: BBR + FQ + ECN + SACK
- I/O optimization for UFS 2.2: `read_ahead=2048`, `nr_requests=64`
- Aggressive Doze and wakelock blocking
- Extended debloat (Sebastián MTZ full list)
- Google tamer (GmsIntentOperationService, hotword, Assistant, Firebase)
- Kernel hardening (ptrace, ASLR, printk)
- Schedtune for UI threads (`boost=1`, `prefer_idle=1`)

---

## [4.0] - 2026-08-15

### 🚀 Added
- First version designed specifically for HyperOS 3 Ports on sweet
- Basic 60Hz lock via HAL
- Basic schedutil tuning (up_rate=500, down_rate=2000)
- Basic debloat (8 packages: analytics, daemon, msa, mipicks, etc.)
- Google Eco-Mode (disabled AnalyticsService, AppMeasurementService)
- VM tuning (dirty_writeback=3000, dirty_expire=1500)

### 🐛 Fixed
- Initial stability fixes for HyperOS 3 environment

---

## [3.0] - 2026-06-17

### 🚀 Added
- **First ever release** of Apex Render
- Initial concept for HyperOS 3 on Redmi Note 10 Pro (sweet)
- Basic 60Hz panel lock via HAL
- CPU frequency collapse via schedutil
- Telemetry freeze (Xiaomi & GMS)
- Push notifications kept intact
- Minimal debloat
- Experimental Eco profile

---

## 📌 Legend

| Tag | Meaning |
| :--- | :--- |
| 🚀 Added | New features or optimizations |
| ⚡ Improved | Enhancements to existing features |
| 🐛 Fixed | Bug fixes |
| 🔒 Security | Security-related changes |
| 📦 Chore | Maintenance, refactoring, or minor changes |
