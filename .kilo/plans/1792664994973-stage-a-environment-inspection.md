# Phase A — Research & Environment Audit Report (Finalized)

## 1. Repository Actual State

| Item | Status |
|------|--------|
| Repository | `gxmotiv/Game-` (GitHub) |
| Branch | `kilo/briny-crane-766` |
| Commits | 1 (initial commit only) |
| Files | `README.md` (minimal), `.kilo/plans/` directory |
| Godot Project | ❌ None yet |
| Export Config | ❌ None yet |
| GitHub Actions | ❌ None yet |

## 2. Local Environment (Kilo Cloud Container)

| Tool | Available | Notes |
|------|-----------|-------|
| Git | ✅ | Standard |
| Node.js | ✅ | `/usr/local/bin/node` (version unknown) |
| npm | ❓ | Not explicitly verified |
| Python3 | ❌ | Not found |
| Java/JDK | ❌ | Not found |
| Godot | ❌ | Not found |
| Android SDK | ❌ | Not found |
| adb | ❌ | Not found |
| NDK/CMake | ❌ | Not found |

**Key Constraint**: No local build tools. All compilation/export must happen on GitHub Actions runners (ubuntu-latest).

## 3. GitHub Actions Environment (ubuntu-latest)

- **OS**: Ubuntu Linux x64 (desktop architecture)
- **Free tier**: 2,000 minutes/month for public repositories
- **Available**: Can install OpenJDK 17, Android SDK, NDK, Godot, export templates
- **Architecture mismatch**: Runner is x64; target device is ARM32 (Android 11, 4GB RAM)

## 4. REA (Reverse Engineer Anything) — Verified Compatibility

### REA Requirements (from upstream docs)
- Node.js 22.x (>=22.19), 24.x (>=24.11), or 26+ + npm
- **Android APK analysis**: Headless JADX + full JDK on Linux/macOS/Windows **x64**
- **Android device analysis**: Caller-supplied adb (emulator or hardware)
- **Native binary analysis**: Hopper, Ghidra, or IDA (commercial/proprietary)
- **Platform**: Desktop x64 only (not ARM, not Android)

### Integration Assessment

| Capability | Available? | Notes |
|------------|------------|-------|
| REA CLI/MCP on phone | ❌ No | Requires Node.js 22+ desktop |
| REA on GitHub Actions | ⚠️ Possible | Runner is x64 Linux; could install Node.js + JADX + JDK |
| Android APK analysis via REA | ⚠️ Possible on CI | Requires JADX + JDK setup in workflow |
| Native binary analysis (Ghidra/Hopper) | ❌ No | Commercial tools, heavy RAM, x64 only |
| Static JS/Electron/.NET analysis | ⚠️ Possible on CI | Node.js only, no native deps |
| Godot PCK inspection | ✅ Built-in | No Godot required; could analyze exported PCK |

**Conclusion**: REA cannot run on the development phone. It *could* run on GitHub Actions for APK/PCK analysis, but adds significant workflow complexity and CI minutes. For Phases A–E, **REA is not a practical dependency**. Its value is as a reference for reverse-engineering methodologies (documented in REA guides/showcases), not as an operational tool in this pipeline.

## 5. Best Suitable Free Resources & Licences

### Game Mechanics Reference Repositories (Legally Accessible)

| Repo | License | Type | Key Mechanics |
|------|---------|------|---------------|
| `DiscoveringGodot/4_Heist_Meisters` | Educational/permissive* | 2D top-down | Guard FOV, raycast LOS, Navigation2D patrol, security cameras, keypad-locked doors, hacking terminals, disguises, loot, win/lose, tutorials |
| `godot-addons/godot-field-of-view` | MIT | 2D addon | Configurable FOV cone, multiple targets, group-based targeting |
| `elyar-jamali/TopDown_Stealth_Game` | Non-commercial only | 3D | Advanced guard vision occlusion, patrol routes, takedowns, ragdoll, tactical map |
| `obscura-tempura-studios/godot-4-stealth-skeleton` (itch.io) | MIT | 2D skeleton | Patrol AI, vision cones, noise system, trap tiles, AI states (patrol→investigate→alert→chase) |

*Heist Meisters: "You're welcome to download, fork or do whatever else legal with all the files!" — educational course companion repo.

### Visual Assets (CC0 / Public Domain)

| Source | License | Content | Notes |
|--------|---------|---------|-------|
| **Kenney.nl** (Retro Urban Kit, RPG Urban Pack, Tiny Town) | CC0-1.0 | 1314 urban sprites: buildings, roads, vehicles, props | Via `GeorgeQLe/assets-2d-city` GitHub mirror with manifest |
| **itch.io CC0 Top-Down** | CC0-1.0 | Various tilesets, characters, UI | Filter by `assets-cc0` + `top-down` tags |
| `Papyszoo/CC0-Public-Domain-Sprites` | CC0-1.0 | Curated sprites, tilesets, UI kits | Verified provenance, clean transparency |
| `Tiddybub/2d-assets` | CC0-1.0 | 1101 asset packs, genre-sorted | Ready-to-use library |

### Audio Assets (CC0 / Public Domain)

| Source | License | Content |
|--------|---------|---------|
| **Kenney.nl Audio Packs** (RPG Audio, Interface Sounds, UI Audio, Impact Sounds, Sci-Fi Sounds, Music Jingles) | CC0-1.0 | 700+ sound effects + 85 music jingles |
| `Mcamento8/open-game-sfx-index` | CC0-1.0 | 1451 sounds indexed, AI-searchable, direct file access |

### Fonts (SIL OFL — Embeddable in Games)

| Font Family | License | Source | Notes |
|-------------|---------|--------|-------|
| **Inter** | SIL OFL 1.1 | Google Fonts / `@fontsource/inter` | Modern UI, excellent readability |
| **JetBrains Mono** | SIL OFL 1.1 | Google Fonts / `@fontsource/jetbrains-mono` | Monospace, good for code/terminal UI |
| **Noto Sans** | SIL OFL 1.1 | Google Fonts / Godot built-in | Multi-script support |
| **Open Sans** | Apache 2.0 | Google Fonts / Godot built-in | Alternative UI font |

**OFL Compliance**: Must ship `OFL.txt` with the build (include in `.pck` or alongside APK). Keep copyright notice intact. Do not sell font alone.

## 6. Zero-Budget APK Build Route — Verified

### Recommended: Manual GitHub Actions Workflow (pazalla/gist approach)

**Why not marketplace actions?**
- `dulvui/godot-android-export@v4` — Archived, no updates, debug-only
- `croconut/godot-multi-builder` — Android debug-only per docs
- Third-party actions add dependency risk

**Manual workflow advantages**:
- Full control over Godot version, templates, SDK versions
- Transparent, auditable, no hidden behavior
- Debug APK focus (no release signing complexity initially)
- Uses Godot's documented environment variables for keystore

### Required CI Steps (ubuntu-latest)

```yaml
# 1. Install OpenJDK 17
# 2. Install Android SDK (cmdline-tools, platform-tools, build-tools 35.0.1, platform 35, cmake, ndk r28b)
# 3. Download Godot 4.4 Linux headless + export templates
# 4. Install templates to ~/.local/share/godot/export_templates/<version>/
# 5. Run: godot --headless --export-debug "Android" build/game.apk
# 6. Verify: aapt dump badging build/game.apk | grep -E "package|application|sdkVersion|abi"
# 7. Upload APK as artifact
```

### ARM32 Verification
- Godot 4.x export templates include `armeabi-v7a` by default
- Must verify `aapt dump badging` shows `armeabi-v7a` in `native-code`
- Test on Android 11 device (4GB RAM)

## 7. Recommended Game Architecture

### Core Decisions (User-Confirmed)

| System | Decision |
|--------|----------|
| **Touch Controls** | Both: Virtual Joystick (left) + Action Buttons (right) **AND** Tap-to-Move with pathfinding; selectable in settings, preference saved. **Default: Virtual Joystick** |
| **Guard Patrol** | All three modes configurable per guard: Loop, Ping-Pong, Random Waypoint |
| **FOV Detection** | Custom lightweight raycast implementation (RayCast2D); **fully configurable per guard via export variables** (angle, range, ray count); walls block LOS via physics raycast |
| **Hacking Mechanic** | Two-stage: (1) Interact terminal → reveals 4-digit code; (2) Enter code at associated locked door; correct code unlocks only that door. **Hybrid codes: fixed for main path, procedural for side content** |
| **Level Format** | TileMapLayer + TileSet with Autotiles (bitmask collision); reusable floor/wall/corner/doorway tiles; separate interactive scenes for guards, terminals, cameras, doors. **Navigation: editor-baked + selective runtime updates for dynamic obstacles** |

### Architecture Principles

```
project_root/
├── project.godot
├── export_presets.cfg
├── .github/workflows/android.yml
├── assets/
│   ├── sprites/        # Kenney urban tilesets, characters
│   ├── audio/          # Kenney CC0 sounds
│   └── fonts/          # Inter, JetBrains Mono (OFL)
├── scenes/
│   ├── world/          # Level scenes (TileMapLayer based)
│   ├── entities/
│   │   ├── player/     # Player.tscn + Player.gd
│   │   ├── guard/      # Guard.tscn + Guard.gd + PatrolRoute.gd
│   │   ├── terminal/   # Terminal.tscn + Terminal.gd
│   │   ├── door/       # Door.tscn + Door.gd (LockedDoor extends)
│   │   └── camera/     # SecurityCamera.tscn + Camera.gd
│   ├── ui/
│   │   ├── hud/        # HUD.tscn (joystick, buttons, health, mini-map)
│   │   ├── menus/      # PauseMenu, Settings, GameOver, Victory
│   │   └── popups/     # KeypadPopup, CodeDisplay, TerminalReadout
│   └── systems/
│       ├── InputManager.gd (autoload)
│       ├── GameManager.gd (autoload)
│       ├── SaveSystem.gd (autoload)
│       └── AudioManager.gd (autoload)
├── scripts/
│   ├── core/           # Base classes, interfaces
│   ├── ai/             # GuardAI, PatrolBehavior, VisionSystem
│   ├── interaction/    # Interactable, Hackable, Lockable
│   └── utils/          # Helpers, constants
└── addons/             # (empty initially; no external addons)
```

### Key Technical Choices

- **Godot Version**: 4.4 (Latest Stable)
- **Export Mode**: Debug APK only for Phase E (no release signing)
- **Graphics Backend**: GLES3 with `rendering_2d/gpu_canvas_shader/allow_gles2` fallback
- **Project Structure**: Repo root (simpler workflow paths)
- **Navigation**: NavigationServer2D + NavigationRegion2D (editor-baked) + NavigationAgent2D; selective runtime updates for doors
- **Vision**: RayCast2D per guard (export variables: cone_angle, cone_range, ray_count, detection_buildup_time)
- **Signals**: Event-driven interaction (terminal → code → door)
- **Save**: JSON-based (player position, guard states, unlocked doors, settings, control scheme preference)

## 8. Principal Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| ARM32 export fails / missing `armeabi-v7a` | Medium | High | Verify `aapt dump badging` in CI; test on device early |
| GitHub Actions minutes exhausted | Low (2000 min/mo) | Medium | Cache Godot + templates; keep builds < 10 min |
| Godot 4.4 Android export template bugs | Medium | High | Pin exact version; test export locally if possible |
| Touch controls feel unresponsive on 4GB device | Medium | High | Profile input latency; optimize UI; test on device |
| Guard vision raycast performance (many rays/frame) | Medium | Medium | Limit ray count; use collision layers; spatial indexing |
| TileMap navigation polygon generation | Medium | Medium | Pre-bake navigation; avoid runtime regeneration |
| Audio latency / memory on 4GB device | Low | Medium | Use OGG compressed; stream music; limit polyphony |
| Save/load corruption on scene reload | Low | High | Versioned save schema; validation; fallback defaults |

## 9. Revised Phased Plan

### Phase A — Research & Environment Audit ✅ **COMPLETE**
- [x] Repository inspection
- [x] Local/remote tool audit
- [x] REA feasibility analysis
- [x] Free resource catalogue (assets, audio, fonts)
- [x] Zero-budget build route selection
- [x] Architecture decisions documented
- [x] Risk register created
- [x] All design decisions resolved

### Phase B — Technical Specification & Project Initialization
**Deliverable**: Godot 4.4 project skeleton at repo root with CI workflow

| Task | Details | Acceptance Criteria |
|------|---------|---------------------|
| B1 | Initialize Godot 4.4 project (`project.godot`, `icon.svg`, basic settings) | Project opens in Godot 4.4; version pinned in `project.godot` |
| B2 | Configure project settings: GLES3 + GLES2 fallback, input map (joystick + tap actions), physics layers | Settings applied; input actions defined; collision layers named |
| B3 | Create `export_presets.cfg` with Android debug preset (package name, orientation, permissions) | Debug preset exports APK; package name `com.example.stealthgame` |
| B4 | Write `.github/workflows/android.yml` (manual setup, cached deps, ARM32 verification) | Workflow runs on push; downloads Godot 4.4 + templates; exports debug APK |
| B5 | Add `THIRD_PARTY_NOTICES.md` with all asset/audio/font licences | Document includes Kenney CC0, OFL fonts, any other sources |
| B6 | Commit & push; verify CI runs (even if export fails initially) | Green CI run (or expected failure only at export step) |

### Phase C — First Playable Prototype (Core Loop)
**Deliverable**: Runnable scene with player, guard, level, basic stealth

| Task | Details | Acceptance Criteria |
|------|---------|---------------------|
| C1 | Create TileSet + TileMapLayer: floor, walls, corners, doorways (autotile bitmasks) | TileSet resource with autotile bitmasks; collision shapes on wall tiles |
| C2 | Build Level 1 scene: small urban district (block layout, navigation polygon) | Scene loads; NavigationRegion2D baked; player can navigate |
| C3 | Implement `Player.gd`: dual control scheme (virtual joystick + tap-to-move), state machine (idle/walk/run/crouch), animation handling | Both schemes work; switchable at runtime; state transitions smooth |
| C4 | Implement `InputManager` autoload: action mappings, scheme switching, persistence | Scheme saved to `user://settings.json`; persists across restarts |
| C5 | Implement `Guard.gd` + `PatrolRoute.gd`: three patrol modes, waypoints, NavigationAgent2D, wait timers | Guards patrol Loop/Ping-Pong/Random per guard; wait at waypoints |
| C6 | Implement custom `VisionSystem.gd`: RayCast2D cone (export vars: angle/range/rays), wall occlusion, detection buildup/decay | Cone respects walls; detection ramps up/down; configurable per guard |
| C7 | Guard AI states: Patrol → Suspicious → Investigate → Chase → ReturnToPatrol | State machine transitions correctly; investigation targets last known position |
| C8 | Basic HUD: joystick (left), action buttons (right), health, mini-map toggle | HUD visible; joystick drag moves player; buttons trigger actions |
| C9 | Pause menu + restart + basic settings (control scheme toggle, volume) | Pause opens menu; restart reloads scene; settings toggle scheme + volume |

### Phase D — Complete Gameplay Loop (Hacking & Objectives)
**Deliverable**: Winnable mission with terminal → code → door flow

| Task | Details | Acceptance Criteria |
|------|---------|---------------------|
| D1 | `Terminal.gd`: Interactable, reveals 4-digit code on interaction, shows readout popup | Terminal interaction shows code; code persists for session |
| D2 | `LockedDoor.gd` (extends `Door.gd`): Requires code, keypad popup on interact, validates, unlocks, signals | Keypad accepts 4 digits; correct code unlocks; wrong code rejects |
| D3 | `SecurityCamera.gd`: Rotating FOV, detects player, triggers alarm (guard alert) | Camera rotates; detection triggers alarm state in nearby guards |
| D4 | Signal wiring: Terminal → (code) → LockedDoor; Camera → Alarm → Guard state change | Reading terminal enables door; alarm makes guards chase |
| D5 | Mission system: Objective tracker (UI), win condition (reach exit), lose condition (detected) | Objective UI updates; exit zone triggers victory; detection triggers game over |
| D6 | GameOver / Victory screens with restart / main menu | Screens show; restart works; main menu returns to title |
| D7 | SaveSystem: Persist player pos, guard states, unlocked doors, settings, control scheme | Save/load works mid-mission; unlocked doors stay unlocked |
| D8 | Polish: Audio (footsteps, door, keypad, alarm), UI feedback, transitions | Sounds play; UI animates; transitions smooth |

### Phase E — Android APK Build & Device Test
**Deliverable**: Installable debug APK verified on target device

| Task | Details | Acceptance Criteria |
|------|---------|---------------------|
| E1 | Trigger GitHub Actions build; monitor logs | Build completes without errors |
| E2 | Download APK artifact; verify `aapt dump badging` shows `armeabi-v7a`, minSdk 21+, targetSdk 35 | `armeabi-v7a` present; SDK versions correct |
| E3 | Transfer to phone (USB/ADB/GitHub release); install | APK installs on Android 11 device |
| E4 | Test on Android 11 device: launch, controls, guard AI, hacking, win/lose, pause, save/load | All core loops functional on device |
| E5 | Profile: RAM usage (target < 300MB), FPS (target 30+), battery, thermal | Meets targets; no thermal throttle in 10 min play |
| E6 | Document defects; iterate fixes in Phase C/D as needed | Defect list created; fixes applied and re-verified |

### Phase F — Performance & Expansion (Incremental)
**Deliverable**: Stable base for ongoing content development

| Task | Details |
|------|---------|
| F1 | Performance optimization: texture atlases, fewer raycasts, object pooling, scene instancing |
| F2 | Additional missions: new districts, guard types, camera networks |
| F3 | Enhanced hacking: timing minigame, memory sequence (optional, behind feature flag) |
| F4 | Visual upgrades: lighting (Light2D), particles, better animations |
| F5 | Audio: ambient tracks, dynamic music layers |
| F6 | Settings expansion: graphics quality, control sensitivity, accessibility |
| F7 | Optional: REA integration for post-mortem APK analysis (CI job, non-blocking) |

---

## First Coding Milestone: Phase B1–B4

### Goal
Initialize Godot 4.4 project at repo root with working GitHub Actions CI that exports a debug APK.

### Files to Create
1. `project.godot` — Godot 4.4 project config (pinned version, renderer settings, input map)
2. `icon.svg` — App icon placeholder
3. `export_presets.cfg` — Android debug export preset
4. `.github/workflows/android.yml` — CI workflow
5. `THIRD_PARTY_NOTICES.md` — License attributions

### Commands / Workflow
```bash
# Local (Kilo container): create files, commit, push
git add .
git commit -m "Phase B: Godot 4.4 project skeleton + CI workflow"
git push origin kilo/briny-crane-766

# GitHub Actions: triggers on push
# - Installs OpenJDK 17
# - Installs Android SDK (cmdline-tools, platform-tools, build-tools 35.0.1, platform 35, cmake, ndk r28b)
# - Downloads Godot 4.4 Linux headless + export templates
# - Runs: godot --headless --export-debug "Android" build/game.apk
# - Verifies: aapt dump badging build/game.apk
# - Uploads APK artifact
```

### Acceptance Criteria
- [ ] `project.godot` specifies `config_version=5` and `rendering_2d/gpu_canvas_shader/allow_gles2=true`
- [ ] Input map includes: `move_left`, `move_right`, `move_up`, `move_down`, `interact`, `crouch`, `pause`, `tap_move`
- [ ] Physics layers named: `player`, `guard`, `wall`, `door`, `camera`, `interactable`
- [ ] `export_presets.cfg` has preset named "Android" with `platform="Android"`, `runnable=true`, `export_filter="all_resources"`
- [ ] `.github/workflows/android.yml` uses `actions/setup-java@v4` (JDK 17), `android-actions/setup-android@v3`, caches Godot + templates
- [ ] CI run completes (export may fail if templates missing — that's expected for first run)
- [ ] `THIRD_PARTY_NOTICES.md` lists Kenney CC0, Inter OFL, JetBrains Mono OFL

---

## Verification Status

| Category | Status | Evidence |
|----------|--------|----------|
| Repository state | ✅ Verified | `git status`, `git log`, `ls` |
| Local tools | ✅ Verified | `which` checks |
| GitHub Actions availability | ✅ Verified | Public repo free tier documented |
| REA compatibility | ✅ Verified | Upstream docs reviewed |
| Asset licenses | ✅ Verified | Source pages checked (Kenney CC0, Google Fonts OFL) |
| Godot Android requirements | ✅ Verified | Official docs reviewed |
| ARM32 support | ⚠️ Assumed | Godot docs state `armeabi-v7a` included; not yet tested |
| CI workflow | 📋 Designed | Based on pazalla/gist; not yet executed |
| Gameplay mechanics | 📋 Designed | Based on Heist Meisters + custom decisions |
| Performance targets | 📋 Specified | Not yet measured |

---

## Next Action
Upon approval, implementation agent begins **Phase B1–B4** (Project Initialization & CI Workflow).

**Saved plan**: `.kilo/plans/1792664994973-stage-a-environment-inspection.md`