# Stage A: Environment Inspection & Tool Availability Report

## Repository State
- **Repository**: `gxmotiv/Game-` (GitHub)
- **Branch**: `kilo/briny-crane-766`
- **Commits**: 1 (initial commit only)
- **Files**: `README.md` (minimal), `.kilo/plans/` directory
- **Status**: Fresh repository, no Godot project yet

## Local Environment (Kilo Cloud Container)
| Tool | Available | Version/Notes |
|------|-----------|---------------|
| Git | Yes | Standard |
| Node.js | Yes | `/usr/local/bin/node` |
| npm | Unknown | Not explicitly verified |
| Python3 | No | Not found |
| Java/JDK | No | Not found |
| Godot | No | Not found |
| Android SDK | No | Not found |
| adb | No | Not found |
| NDK/CMake | No | Not found |

**Key Constraint**: No local build tools. All compilation/export must happen on GitHub Actions runners (ubuntu-latest).

## GitHub Actions Environment (ubuntu-latest)
- **OS**: Ubuntu Linux x64 (desktop architecture)
- **Free tier**: 2,000 minutes/month for public repos
- **Available tools**: Can install OpenJDK 17, Android SDK, NDK, Godot, export templates
- **Architecture mismatch**: Runner is x64; target device is ARM32 (Android 11, 4GB RAM)

## REA (Reverse Engineer Anything) Analysis

### REA Requirements (from upstream docs)
- Node.js 22.x (>=22.19), 24.x (>=24.11), or 26+ + npm
- **For Android APK analysis**: Headless JADX + full JDK on Linux/macOS/Windows **x64**
- **For Android device analysis**: Caller-supplied adb (emulator or hardware)
- **For native binary analysis**: Hopper, Ghidra, or IDA (commercial/proprietary)
- **Platform**: Desktop x64 only (not ARM, not Android)

### REA Integration Assessment
| Capability | Available in Our Setup? | Notes |
|------------|------------------------|-------|
| REA CLI/MCP on phone | ❌ No | Requires Node.js 22+ desktop |
| REA on GitHub Actions | ⚠️ Possible | Runner is x64 Linux; could install Node.js + JADX + JDK |
| Android APK analysis via REA | ⚠️ Possible on CI | Requires JADX + JDK setup in workflow |
| Native binary analysis (Ghidra/Hopper) | ❌ No | Commercial tools, heavy RAM, x64 only |
| Static JS/Electron/.NET analysis | ⚠️ Possible on CI | Node.js only, no native deps |
| Godot PCK inspection | ✅ Built-in to REA | No Godot required; could analyze exported PCK |

**Conclusion**: REA cannot run on the development phone. It *could* run on GitHub Actions for APK/PCK analysis, but adds significant workflow complexity and CI minutes. For Stage A–D, **REA is not a practical dependency**. Its value is as a reference for reverse-engineering methodologies (documented in REA guides/showcases), not as an operational tool in this pipeline.

## Godot 4 Android Export Requirements

### Mandatory Dependencies (per Godot 4.7 docs)
1. **OpenJDK 17** (recommended; higher versions work)
2. **Android SDK** with:
   - Platform-Tools 35.0.0+
   - Build-Tools 35.0.1
   - Platform android-35 (API 35)
   - Command-line Tools (latest)
   - CMake 3.10.2.4988404
   - NDK r28b (28.1.13356709)
3. **Godot 4.x Linux headless editor** (x64)
4. **Godot Export Templates** matching Godot version (`.tpz`)

### ARM32 Compatibility Notes
- Godot 4.x export templates include `armeabi-v7a` (32-bit ARM) by default
- Android 11 (API 30) is supported by Godot 4.x
- Must verify APK `abiFilters` or `ndk.abiFilters` includes `armeabi-v7a`
- 4GB RAM target: keep APK < 100MB, minimize texture sizes, use GLES2/GLES3 compatibility mode

## GitHub Actions Workflow Options (Researched)

### Option 1: Manual Setup (pazalla/gist approach)
- Download Godot + templates via `wget`
- Install to `/usr/local/bin` and `~/.local/share/godot/export_templates/`
- Run `godot --headless --export-release|--export-debug`
- **Pros**: Full control, no third-party action dependency
- **Cons**: More verbose, manual version management

### Option 2: `dulvui/godot-android-export@v4` (Marketplace Action)
- Handles Godot + template download + Android SDK setup internally
- Requires `export_presets.cfg` and `export_credentials.cfg`
- **Pros**: Simpler workflow, maintained
- **Cons**: Archived (v4.1.0), no further updates; debug-only per docs

### Option 3: `croconut/godot-multi-builder` or `firebelley/godot-export`
- Multi-platform builders
- **Cons**: Android often debug-only; extra complexity

### Recommended Approach
**Hybrid**: Use manual setup (Option 1) for transparency and debug APK focus. Avoid release signing complexity initially. Use environment variables for keystore/credentials per Godot docs.

## Open-Source Stealth Game References (Legally Accessible)

| Repo | License | Type | Key Mechanics Demonstrated |
|------|---------|------|---------------------------|
| `DiscoveringGodot/4_Heist_Meisters` | Educational/permissive* | 2D top-down | Guard FOV, raycast LOS, Navigation2D patrol, security cameras, keypad-locked doors, hacking terminals (computers), disguises, loot, win/lose, tutorials |
| `godot-addons/godot-field-of-view` | MIT | 2D addon | Configurable FOV cone, multiple targets, group-based targeting |
| `elyar-jamali/TopDown_Stealth_Game` | Non-commercial only | 3D | Advanced guard vision occlusion, patrol routes, takedowns, ragdoll, tactical map |
| `obscura-tempura-studios/godot-4-stealth-skeleton` (itch.io) | MIT | 2D skeleton | Patrol AI, vision cones, noise system, trap tiles, AI states (patrol→investigate→alert→chase) |

*Heist Meisters: "You're welcome to download, fork or do whatever else legal with all the files!" — educational course companion repo.

## Stage A Summary

### What Exists
- Empty GitHub repo with Git history
- Node.js available in cloud container
- GitHub Actions free tier for CI/CD

### What's Missing (Must Be Created/Configured)
1. Godot 4 project structure (`project.godot`, scenes, scripts)
2. Android export preset (`export_presets.cfg`)
3. Debug keystore (auto-generated by Godot) or custom debug keystore
4. GitHub Actions workflow (`.github/workflows/android.yml`)
5. Game prototype: player, guard, FOV, terminal, door, win/lose, pause/menu

### ARM32 Verification Strategy
- Export debug APK via GitHub Actions
- Upload as artifact
- Download to phone, install, verify `aapt dump badging` shows `armeabi-v7a`
- Test on Android 11 device (4GB RAM)

## Stage A Decision Points (Require Approval)

1. **Godot Version**: Use Godot 4.3 (stable LTS) or 4.4 (latest stable)?
   - *Recommendation*: **Godot 4.3** — LTS, well-tested export templates, matches Heist Meisters reference.

2. **Export Mode**: Debug-only APK for Stage D (no release signing)?
   - *Recommendation*: **Yes** — Debug APK installs directly; release signing adds keystore complexity for later.

3. **Graphics Backend**: GLES3 (default) or GLES2 compatibility?
   - *Recommendation*: **GLES3** with `rendering_2d/gpu_canvas_shader/allow_gles2` fallback; test on device.

4. **Project Structure**: Godot project at repo root or subdirectory?
   - *Recommendation*: **Repo root** — simpler workflow paths.

5. **REA Integration**: Defer to post-MVP (Stage F+) as research reference only?
   - *Recommendation*: **Yes** — Not operationally viable in current pipeline.

---

## Next Step (Stage B → C Transition)
Upon approval of the above decisions, proceed to **Stage C: Minimal Game Prototype** with:
- Godot 4.3 project initialization
- 2D top-down scene (TileMap + player + guard)
- Touchscreen movement (virtual joystick or tap-to-move)
- Guard patrol (Navigation2D + waypoints)
- FOV detection (raycast + angle check)
- One interactive terminal (popup UI)
- One hackable door (signal-based unlock)
- Win/lose + pause/restart/settings

**Estimated files to create**: ~15–20 GDScript files, 5–8 scenes, export config, GitHub Actions workflow.