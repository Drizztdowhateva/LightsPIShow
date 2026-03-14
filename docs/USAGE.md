# Usage

Runtime usage guide for Lights PI Show on Raspberry Pi/Linux.

## Launcher Overview

- `./Lights.sh` launches the CLI runtime (`into.py`).
- `./Lights_GUI.sh` launches the GTK GUI (`gui.py`).
- Both launchers:
	- create/use `.venv`
	- check dependencies
	- prompt before installing missing packages
	- support `--yes` for non-interactive installs
	- support `--help` for launcher options

## CLI Launcher

Show launcher help:

```bash
./Lights.sh --help
```

Interactive run:

```bash
./Lights.sh
```

Headless run with default config:

```bash
sudo ./Lights.sh --headless --headless-config headless/headless_settings.json
```

Non-interactive dependency/pip prompts:

```bash
./Lights.sh --yes --test --pattern 5 --speed 6
```

## GUI Launcher

Show launcher help:

```bash
./Lights_GUI.sh --help
```

Normal hardware run:

```bash
./Lights_GUI.sh
```

Simulation run:

```bash
./Lights_GUI.sh --test
```

Non-interactive dependency/pip prompts:

```bash
./Lights_GUI.sh --yes
```

## Raspberry Pi Hardware Notes

- GUI and CLI do not force simulation mode unless you explicitly request `--test`
	(or enable the GUI test checkbox).
- If hardware init fails, the GUI now shows a hardware error instead of silently
	switching to test mode.
- For LED hardware access, either run with `sudo` or grant capabilities once:

```bash
sudo bash setup_permissions.sh
```

Then run normally:

```bash
./Lights_GUI.sh
./Lights.sh
```

## Background Runtime Shortcut (CLI)

While running the CLI runtime, press `O` to print the generated `nohup` command
for the current settings. That command writes:

- `runtime_live.log` for logs
- `runtime_live.pid` for process ID

Stop background runtime:

```bash
kill $(cat runtime_live.pid) 2>/dev/null || echo "No running process found"
```
