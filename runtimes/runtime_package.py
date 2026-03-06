#!/usr/bin/env python3
"""Cross-platform packaging runtime for Lights PI Show.

Targets:
- appimage (Linux)
- exe      (Windows)
- dmg      (macOS)

This script consolidates packaging logic in one place and exposes thin wrappers
for each output type.
"""

from __future__ import annotations

import argparse
import platform
import shutil
import subprocess
import sys
from pathlib import Path


APP_NAME = "LightsPIShow"
ROOT = Path(__file__).resolve().parent.parent
ENTRYPOINT = ROOT / "into.py"
DIST_DIR = ROOT / "dist"


def run(cmd: list[str]) -> None:
    print("+", " ".join(cmd))
    subprocess.check_call(cmd)


def ensure_pyinstaller(skip_install: bool) -> None:
    if skip_install:
        return
    run([sys.executable, "-m", "pip", "install", "pyinstaller"])


def build_with_pyinstaller(extra_args: list[str]) -> None:
    cmd = [
        sys.executable,
        "-m",
        "PyInstaller",
        "--noconfirm",
        "--clean",
        "--name",
        APP_NAME,
    ]
    cmd.extend(extra_args)
    cmd.append(str(ENTRYPOINT))
    run(cmd)


def package_appimage() -> None:
    if platform.system() != "Linux":
        raise SystemExit("AppImage packaging must be run on Linux.")

    build_with_pyinstaller(["--onefile"])
    binary = DIST_DIR / APP_NAME
    if not binary.exists():
        raise SystemExit(f"Missing expected binary: {binary}")

    appimagetool = shutil.which("appimagetool")
    if not appimagetool:
        print("appimagetool not found. Built Linux binary only:")
        print(f"  {binary}")
        return

    appdir = ROOT / "build" / "AppDir"
    if appdir.exists():
        shutil.rmtree(appdir)

    (appdir / "usr" / "bin").mkdir(parents=True, exist_ok=True)
    shutil.copy2(binary, appdir / "usr" / "bin" / APP_NAME)

    apprun = appdir / "AppRun"
    apprun.write_text(
        "#!/bin/sh\n"
        "HERE=\"$(dirname \"$(readlink -f \"$0\")\")\"\n"
        "exec \"$HERE/usr/bin/LightsPIShow\" \"$@\"\n",
        encoding="utf-8",
    )
    apprun.chmod(0o755)

    desktop = appdir / f"{APP_NAME}.desktop"
    desktop.write_text(
        "[Desktop Entry]\n"
        "Type=Application\n"
        "Name=Lights PI Show\n"
        "Exec=LightsPIShow\n"
        "Terminal=true\n"
        "Categories=Utility;\n",
        encoding="utf-8",
    )

    arch = platform.machine() or "x86_64"
    output = DIST_DIR / f"{APP_NAME}-{arch}.AppImage"
    run([appimagetool, str(appdir), str(output)])
    print(f"Created: {output}")


def package_exe() -> None:
    if platform.system() != "Windows":
        raise SystemExit("EXE packaging must be run on Windows.")

    build_with_pyinstaller(["--onefile"])
    exe = DIST_DIR / f"{APP_NAME}.exe"
    if not exe.exists():
        raise SystemExit(f"Missing expected EXE: {exe}")
    print(f"Created: {exe}")


def package_dmg() -> None:
    if platform.system() != "Darwin":
        raise SystemExit("DMG packaging must be run on macOS.")

    build_with_pyinstaller(["--windowed"])
    app_bundle = DIST_DIR / f"{APP_NAME}.app"
    if not app_bundle.exists():
        raise SystemExit(f"Missing expected app bundle: {app_bundle}")

    hdiutil = shutil.which("hdiutil")
    if not hdiutil:
        raise SystemExit("hdiutil is required to create DMG on macOS.")

    dmg = DIST_DIR / f"{APP_NAME}.dmg"
    if dmg.exists():
        dmg.unlink()

    run(
        [
            hdiutil,
            "create",
            "-volname",
            APP_NAME,
            "-srcfolder",
            str(app_bundle),
            "-ov",
            "-format",
            "UDZO",
            str(dmg),
        ]
    )
    print(f"Created: {dmg}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Build runtime packages for AppImage, EXE, or DMG."
    )
    parser.add_argument("target", choices=["appimage", "exe", "dmg"])
    parser.add_argument(
        "--skip-install",
        action="store_true",
        help="Skip installing/updating PyInstaller before packaging.",
    )
    args = parser.parse_args()

    if not ENTRYPOINT.exists():
        raise SystemExit(f"Missing entrypoint: {ENTRYPOINT}")

    ensure_pyinstaller(skip_install=args.skip_install)

    if args.target == "appimage":
        package_appimage()
    elif args.target == "exe":
        package_exe()
    elif args.target == "dmg":
        package_dmg()


if __name__ == "__main__":
    main()
