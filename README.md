# WS281X Pattern Runner 🚀

![CI](https://github.com/Drizztdowhateva/Lights_PI_Show/actions/workflows/ci.yml/badge.svg)
![License](https://img.shields.io/badge/license-MIT-green)
![Python](https://img.shields.io/badge/python-3.8%2B-blue)

Beautiful, keyboard-driven LED patterns for WS281X strips — with safe ASCII simulation, headless JSON configs, and easy detached runtime options.

## Quick Start ✨

Run a quick ASCII test (no hardware needed):

```bash
python3 into.py --test --pattern 1 --chase-color 4 --speed 3 --frames 20
```

## Donate & GitHub ❤️

- Donation (Cash App): https://cash.app/$teerRight
- GitHub Profile: https://github.com/Drizztdowhateva
- Full page with QR codes: [DONATION_AND_GITHUB_QR.md](DONATION_AND_GITHUB_QR.md)

## Run (hardware) — Easiest mode 🔧

The simplest way to start the pattern runner on a Raspberry Pi:

```bash
sudo ./runtime.sh
```

This starts the runner using the default headless config (`headless/headless_settings.json`) — no interactive prompts. Pass any `into.py` arguments directly to override:

```bash
sudo ./runtime.sh --pattern 3 --speed 3
sudo ./runtime.sh --headless --headless-config headless/emergency_sos_red.json
sudo ./runtime.sh --test --frames 40    # ASCII simulation, no hardware
```

> **Heads up (Ctrl+O):** While the runner is active, press **Ctrl+O** to print the
> equivalent `nohup` background launch command for the current settings along
> with the stop command (`kill $(cat runtime_live.pid)`).

## One-file Python launcher (install + run) 🧰

Installs required runtime package(s) from `requirements.txt` and then runs `into.py`:

```bash
python3 runtime.py -- --pattern 1 --chase-color 4 --speed 3 --frames 0
# or run detached with nohup:
sudo python3 runtime.py --skip-install --no-save --nohup -- --pattern 1 --chase-color 4 --speed 3 --frames 0
```

When using `--nohup` the launcher prints a clear "Heads Up" banner with the command, log file, and stop instructions, then writes a PID file (`runtime_live.pid`):

```bash
kill $(cat runtime_live.pid)
```

## Headless mode & configs 📁

JSON configs live in the `headless/` folder and let you run without interactive prompts.
The following configs are included out of the box:

| File | Pattern | Description |
|------|---------|-------------|
| `headless_settings.json` | Chase (Orange, Medium) | Default startup config |
| `chase_rainbow.json` | Chase (Rainbow, Fast) | Fast rainbow chase |
| `random_warm.json` | Random (Warm palette) | Warm-color random fill |
| `bounce_blue.json` | Bounce (Blue) | Blue bounce |
| `emergency_sos_red.json` | **Emergency SOS** | 🚨 Emergency flag ON — SOS in red |

Load a headless config and run:

```bash
python3 into.py --headless --headless-config headless/headless_settings.json
python3 into.py --headless --headless-config headless/emergency_sos_red.json
```

Interactive menu — the startup prompt shows the first four `headless/*.json` files as
selectable options (a–d), with option `e` to enter a custom path.

Export current settings into a headless JSON file:

```bash
python3 into.py --export-headless          # writes headless/<pattern>_<name>.json
python3 into.py --export-headless my_sos   # writes headless/my_sos.json
```

## Features & handy commands 💡

- Pi input support: digital or analog

```bash
python3 into.py --pi-input-mode digital --pi-input-pin 23
python3 into.py --pi-input-mode analog --analog-path /sys/bus/iio/devices/iio:device0/in_voltage0_raw --analog-max 4095
```

- Brightness control

```bash
python3 into.py --brightness 128 --max-brightness 200
# Runtime keys: + / - to adjust brightness
```

- Timer options

```bash
python3 into.py --frames 600 --duration-seconds 30 --start-delay-seconds 2
```

- Emergency-only panic mode (SOS in 3 repeating colors):

```bash
python3 into.py --emergency-only
```

## Interactive Controls (while running) ⌨️

- `1`/`2`/`3`/`4` — Switch pattern
- `p` — Cycle pattern
- `s` — Cycle speed
- `c` — Cycle color option for current pattern
- `+` / `-` — Adjust brightness
- `h` — Show help
- `q` or `Ctrl+C` — Quit

## Example Output (ASCII)

Pattern: Chase | Speed: Fast | Color: Rainbow
Pattern: Random | Speed: Fast | Palette: Any RGB
Pattern: Bounce | Speed: Fast | Color: Blue

---

If you'd like, I can also update the README examples to use `headless/` everywhere and add screenshots or animated GIFs for the ASCII output.
