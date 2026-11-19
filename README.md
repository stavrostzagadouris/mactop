# mactop
NOTE: This is the macOS sibling of [ptop](https://github.com/stavrostzagadouris/powershellTop) (Windows) and [shtop](https://github.com/stavrostzagadouris/shelltop) (Linux). Feel free to use it if you want.

> 🪟 **On Windows?** Check out **[ptop](https://github.com/stavrostzagadouris/powershellTop)**, the original Windows version.
> 🐧 **On Linux?** Check out **[shtop](https://github.com/stavrostzagadouris/shelltop)**, the Linux version.

A fast, flicker-free, **zero-root** `btop`-style Terminal UI (TUI) system and GPU monitor for macOS (Apple Silicon & Intel), written as a single standalone Python 3 script with **no dependencies** beyond the standard library.

It has the same layout, themes and keys as `ptop` and `shtop`. Under the hood it talks directly to Mach kernel APIs, `libproc`, `sysctl`, `IOKit`/`IORegistry`, `IOHIDEventSystem`, `AppleSMC`, and `libIOReport` via `ctypes` and `ioreg`, so no daemons, Homebrew packages, Xcode tools or `sudo` are needed.

---

## ✨ Features

* **Zero root, zero dependencies:** Python 3.8+ standard library only (ships with macOS). Works over SSH and on locked-down Macs without `sudo`.
* **Apple Silicon & Intel GPU telemetry (via `IOAccelerator` / `AGXAccelerator` & `libIOReport`):**
  * Live **GPU Core %** meter + history sparkline (`Device Utilization %`)
  * **VRAM / Unified Memory (UMA)** in-use and total capacity, **GPU Power Draw** (`W`), **GPU Temperature**, **Fan %**, **GPU Core Clock (`MHz`)**, and **Renderer %**
  * **Per-process GPU activity (`%` and active Metal/GPU contexts)** from `IOUserClientCreator` and `accumulatedGPUTime` deltas in the IORegistry — without root!
* **CPU & RAM:** overall + **per-core grid** (`P`) via Mach `host_processor_info(PROCESSOR_CPU_LOAD_INFO)` with **Performance + Efficiency core count** (`P+E`), Activity Monitor-style **RAM** (App Memory + Wired + Compressed) via `host_statistics64(HOST_VM_INFO64)`, and **Swap** via `vm.swapusage`.
* **CPU temperature, clock and power (zero `sudo`):**
  * **Apple Silicon:** CPU core temperatures from the `pACC`/`eACC` MTR sensors (`IOHIDEventSystemClient`) or the SMC core die sensors (`Tp??`), with **per-core temperatures** in the `P` grid on 10-core M1 Pro/Max; live **CPU & GPU power (W)** from `libIOReport` (`Energy Model`), falling back to the SMC CPU rail (`PSVC`) where macOS no longer updates the CPU energy counter (macOS 27); and active **CPU/GPU frequency** weighted across DVFS residency states (`CPU Stats` / `GPU Stats` + `pmgr` SRAM voltage states).
  * **Intel Macs:** temperatures, power and fan speeds via user-space `AppleSMC` keys (`TC0P`/`TC0D`, `TG0P`, `PCPC`, `F0Ac`/`F0Mx`) and `hw.cpufrequency`.
* **Disks & network:** capacity bars per real APFS container / mounted volume (automatically collapsing macOS's firmlinked `/System/Volumes/Data` duplicate and hidden system volumes) via `getfsstat`, live **Read/Write** throughput from `IOBlockStorageDriver`, plus **Download/Upload** rates and 64-bit wrap-safe totals for physical `en*` NICs via `getifaddrs(AF_LINK)` (skipping `utun`/`awdl`/`llw`/`bridge` tunnels so traffic isn't double-counted).
* **Battery (MacBooks):** charge % plus charging status or time remaining in the header from `AppleSmartBattery`, hidden on desktop Macs (Mac mini, Mac Studio, iMac, Mac Pro).
* **Interactive process manager:** sort by CPU / memory / GPU / disk I/O, filter with `/`, and scroll the whole list with `↑`/`↓`, `PgUp`/`PgDn`, `Home`/`End`. The highlight stays on the process you picked while the list re-sorts. `K` asks before it kills: `Y` sends SIGTERM, `9` sends SIGKILL.
* **Threads and disk I/O columns** on windows 96+ columns wide via `libproc` (`proc_pidinfo` & `proc_pid_rusage`).
* **5 TrueColor themes:** Midnight, Cyberpunk, Matrix, Gruvbox, Nord
* **Flicker-free:** alternate screen buffer and single-write frames. Redraws instantly on a key press or terminal resize.

---

## 🖥️ Interface Layout

```
 mactop │ macbook-pro │ Up: 4d 11h 20m │ Bat: 88% (3h 45m left) │ 1000ms   [P]Cores [T]heme [C/M/G/I]Sort [↑↓/K]Kill [Q]uit │ 15:30:00
╭─ CPU (Apple M3 Max) ────────────────────────────────╮╭─ GPU (Apple M3 Max · 40-Core) ──────────────────────╮
│ CPU Total  ████████░░░░░░░░░░░░░░░░░░░░░  26.4%     ││ GPU Core   ██████████████░░░░░░░░░░░  61.0%         │
│ History    ▁▂▃▄▃▂▁▂▃▅▆▄▃▂▁▂▃▄▃▂▁▂▃▄▅▄▃▂▁▂▃▄▃▂▁▂▃    ││ History    ▁▁▂▄▆▇▆▅▄▅▆▇█▇▆▅▄▅▆▆▅▄▃▄▅▆▅▄▅▆▅▄▃▄▅▆    │
│ RAM        ███████████░░░░░░░░░░░░░░░░░░ 28.4/64.0G ││ VRAM (UMA) ██████████░░░░░░░░░░░ 14.8/64.0G (23%)   │
│ Swap       ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0.0/2.0G  ││ Power      24.5W                                    │
│ Cores: 16 (12P+4E)  Procs: 418  Temp: 58°C  Pwr: 9… ││ Temp: 61°C  Fan: 32%  Clocks: 1398MHz  Renderer: 5… │
├─ Disks ─────────────────────────────────────────────┤├─ Network (en0) ─────────────────────────────────────┤
│ /     ████████░░░░  412/926G  44% R 1.2M/s W 640K/s ││ ▼ Download 12.45 MB/s     Total RX: 48.21 GB        │
│                                                     ││ ▲ Upload   420.5 KB/s     Total TX: 6.14 GB         │
╰─────────────────────────────────────────────────────╯╰─────────────────────────────────────────────────────╯
╭─ Processes (Sort: CPU │ 1/418 │ [/]Filter │ GPU Apps: 5 │ Theme: Midnight) ────────────────────────────────╮
│     PID  PROCESS NAME                                        CPU %   MEM (MB)   MEM %   THR   DISK IO  GPU STATUS          │
│     612  WindowServer                                         8.4%     642.1M    1.0%    14     12K/s  ● M3 Max (18%)      │
╰────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

---

## 🚀 Quick Start

```bash
git clone https://github.com/stavrostzagadouris/mactop.git
cd mactop
./mactop
```

### Install the `mactop` alias (optional)
Run the included installer to add a `mactop` alias to your shell config (`~/.zshrc`, `~/.bashrc` or fish `config.fish`, picked from `$SHELL`):
```bash
./install.sh
```

Or add the alias manually:
```bash
echo "alias mactop='$PWD/mactop'" >> ~/.zshrc
. ~/.zshrc
mactop
```

---

## ⌨️ Keyboard Controls

| Key | Action |
| :--- | :--- |
| **`C`** | Sort processes by **CPU %** |
| **`M`** | Sort processes by **Memory Usage** |
| **`G`** | Sort **Active GPU processes** to the top |
| **`I`** | Sort processes by **disk I/O rate** |
| **`P`** | Toggle **Per-Core CPU Utilization** grid |
| **`T`** | Cycle **Color Themes** (*Midnight → Cyberpunk → Matrix → Gruvbox → Nord*) |
| **`↑` / `↓`** | Move process selection up / down (the list scrolls) |
| **`PgUp` / `PgDn`** | Move the selection a page at a time |
| **`Home` / `End`** | Jump to the top (and stop following a process) / bottom of the list |
| **`K` / `Del`** | Kill the highlighted process, after asking: **`Y`** sends **SIGTERM**, **`9`** sends **SIGKILL**, any other key cancels |
| **`/`** | Filter processes by name or PID (`Enter` keeps the filter, `Esc` clears it) |
| **`+` / `-`** | Speed up / slow down the refresh interval (`250ms` – `5000ms`) |
| **`Q` / `Esc` / `Ctrl+C`** | Quit and restore the terminal (`Esc` clears an active filter first) |

---

## ⚙️ Command-Line Options

```bash
mactop -r 500          # refresh every 500 ms (alias: --refresh-ms)
mactop -t gruvbox      # start with a different theme (alias: --theme)
```

---

## 🧠 How It Works Without Root (`sudo`)

1. **CPU:** Mach `host_processor_info` (`PROCESSOR_CPU_LOAD_INFO`) tick deltas per logical core. CPU brand and P/E core counts come from `sysctl` (`machdep.cpu.brand_string`, `hw.perflevel0.logicalcpu`, `hw.perflevel1.logicalcpu`).
2. **Memory:** Mach `host_statistics64` (`HOST_VM_INFO64`), calculating used memory the same way Activity Monitor does (`internal - purgeable + wired + compressor`). Swap comes from `sysctl("vm.swapusage")`.
3. **GPU:** `ioreg -a -r -c IOAccelerator` exposes the `AGXAccelerator` / `IOAccelerator` `PerformanceStatistics` dictionary (`Device Utilization %`, `Renderer Utilization %`, `In use system memory`, `gpu-core-count`) plus child `IOUserClientCreator` nodes with `accumulatedGPUTime` nanosecond counters for per-process GPU `%`.
4. **CPU & GPU sensors:**
   * **Temperatures:** `IOHIDEventSystemClient` (`PrimaryUsagePage = 0xFF00, PrimaryUsage = 5`) reads the Apple Silicon `pACC`/`eACC` MTR core sensors in user space. Where those don't exist (e.g. Mac Studio), the `AppleSMC` core die sensors (`Tp??`/`Te??`/`Tf??`) and GPU sensors (`Tg??`) are used instead; the PMU's own `tdie` sensors sit near ambient, so they're only a last resort. Intel Macs use `TC0P`/`TG0P`.
   * **Power & Clocks:** `libIOReport.dylib` (`Energy Model`, `CPU Stats`, `GPU Stats`) combined with `pmgr` DVFS frequency tables from `IODeviceTree:/arm-io/pmgr` gives CPU & GPU package watts and active MHz without `sudo`. When the CPU energy counter doesn't move (macOS 27), CPU watts come from the SMC CPU rail key `PSVC`, which tracks `sudo powermetrics` to within ~1 W from idle to full load on an M1 Max.
   * **Fans:** `AppleSMC` user client reads `FNum` and `F0Ac`/`F0Mx` RPMs.
5. **Processes:** `libproc` (`proc_listpids`, `proc_pidinfo(PROC_PIDTASKINFO)`, `proc_pidpath`, and `proc_pid_rusage(RUSAGE_INFO_V2)`) with `mach_timebase_info` scaling for Apple Silicon Mach ticks and `ri_phys_footprint` / `ri_diskio_bytesread` / `ri_diskio_byteswritten`, plus a fast `/bin/ps` fallback for other users' processes.
6. **Disks:** `getfsstat` for mounted volumes (deduplicating APFS container volumes and `/System/Volumes/Data`) and `IOBlockStorageDriver` in IORegistry for live read/write bytes/sec.
7. **Network:** `getifaddrs` (`AF_LINK` `if_data`) across physical `en*` interfaces with 32-bit counter wrap handling.
8. **Battery:** `AppleSmartBattery` in IORegistry.

---

## 🙌 Credits

Original `ptop` and `mactop` by **Argo** (*Gemini 4 Argon*) in collaboration with **stavros**. Linux `shtop` port by **Claude**.

## 📄 License

Released under the [MIT License](LICENSE).
