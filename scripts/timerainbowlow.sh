#!/usr/bin/env bash
set -euo pipefail

sudo sh -c 'nohup /home/blackmox/code/LightsPiShow/.venv/bin/python3 /home/blackmox/code/LightsPiShow/into.py --speed 8 --chase-color 1 --random-palette 1 --bounce-color 1 --brightness 15 --max-brightness 255 --pi-input-mode off --pi-input-pin 23 --analog-path /sys/bus/iio/devices/iio:device0/in_voltage0_raw --analog-max 4095 --effect-color 3 --pattern 7 --schedule-enable --schedule-on 1800 --schedule-off 0600 > /home/blackmox/code/LightsPiShow/runtime_live.log 2>&1 & echo $! > /home/blackmox/code/LightsPiShow/runtime_live.pid'
