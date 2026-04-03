#!/usr/bin/env sh
set -euo pipefail

sudo sh -c 'nohup /home/blackmox/code/LightsPiShow/.venv/bin/python3 /home/blackmox/code/LightsPiShow/into.py --speed 3 --chase-color 4 --random-palette 1 --bounce-color 1 --brightness 32 --max-brightness 255 --pi-input-mode off --pi-input-pin 23 --analog-path /sys/bus/iio/devices/iio:device0/in_voltage0_raw --analog-max 4095 --effect-color 3 --pattern 2 --schedule-enable --schedule-on 19:00 --schedule-off 06:00 --force > runtime_live.log 2>&1 & echo $! > runtime_live.pid'
