# Packaging Runtimes

This folder consolidates packaging runtimes for three distribution formats:

- `runtime_appimage.sh` for Linux AppImage
- `runtime_exe.ps1` for Windows EXE
- `runtime_dmg.sh` for macOS DMG

All wrappers call `runtime_package.py`, which holds shared packaging logic.

## Usage

Linux AppImage:

```bash
bash runtimes/runtime_appimage.sh
```

Windows EXE:

```powershell
powershell -ExecutionPolicy Bypass -File .\runtimes\runtime_exe.ps1
```

macOS DMG:

```bash
bash runtimes/runtime_dmg.sh
```

## Notes

- EXE builds must be run on Windows.
- DMG builds must be run on macOS.
- AppImage builds must be run on Linux.
- `PyInstaller` is installed automatically unless `--skip-install` is passed.
