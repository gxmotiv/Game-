# Third-Party Notices

This document lists all third-party assets, libraries, and resources used in this project, along with their respective licenses.

---

## Visual Assets

### Kenney.nl Asset Packs
**Source**: https://kenney.nl/assets
**License**: CC0 1.0 Universal (Public Domain Dedication)
**Packs Used** (planned):
- Retro Urban Kit
- RPG Urban Pack
- Tiny Town

**License Text**:
```
CC0 1.0 Universal (CC0 1.0) Public Domain Dedication

The person who associated a work with this deed has dedicated the work to
the public domain by waiving all of their rights to the work worldwide
under copyright law, including all related and neighboring rights,
to the extent allowed by law.

You can copy, modify, distribute and perform the work, even for commercial
purposes, all without asking permission.

See https://creativecommons.org/publicdomain/zero/1.0/ for more information.
```

---

### GeorgeQLe/assets-2d-city (GitHub Mirror)
**Source**: https://github.com/GeorgeQLe/assets-2d-city
**License**: CC0 1.0 Universal
**Content**: Kenney urban sprites mirror with manifest

---

### Papyszoo/CC0-Public-Domain-Sprites
**Source**: https://github.com/Papyszoo/CC0-Public-Domain-Sprites
**License**: CC0 1.0 Universal
**Content**: Curated sprites, tilesets, UI kits

---

### Tiddybub/2d-assets
**Source**: https://github.com/Tiddybub/2d-assets
**License**: CC0 1.0 Universal
**Content**: 1101 asset packs, genre-sorted

---

## Audio Assets

### Kenney.nl Audio Packs
**Source**: https://kenney.nl/assets
**License**: CC0 1.0 Universal
**Packs Used** (planned):
- RPG Audio
- Interface Sounds
- UI Audio
- Impact Sounds
- Sci-Fi Sounds
- Music Jingles

**License Text**: Same as Kenney.nl visual assets above (CC0 1.0)

---

### Mcamento8/open-game-sfx-index
**Source**: https://github.com/Mcamento8/open-game-sfx-index
**License**: CC0 1.0 Universal
**Content**: 1451 sounds indexed, AI-searchable

---

## Fonts

### Inter
**Source**: Google Fonts / https://fonts.google.com/specimen/Inter
**License**: SIL Open Font License 1.1 (OFL)
**Copyright**: 2016 The Inter Project Authors (https://github.com/rsms/inter)

**License Text**:
```
SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007

PREAMBLE
The goals of the Open Font License (OFL) are to stimulate worldwide
development of collaborative font projects, to support the font creation
efforts of academic and linguistic communities, and to provide a free and
open framework in which fonts may be shared and improved in partnership
with others.

...

Full license: https://scripts.sil.org/OFL
```

**OFL Compliance**: OFL.txt must be included with the build. Copyright notice kept intact. Font not sold independently.

---

### JetBrains Mono
**Source**: Google Fonts / https://fonts.google.com/specimen/JetBrains+Mono
**License**: SIL Open Font License 1.1 (OFL)
**Copyright**: 2020 JetBrains (https://www.jetbrains.com/)

**License Text**: Same SIL OFL 1.1 as above.

**OFL Compliance**: OFL.txt must be included with the build. Copyright notice kept intact. Font not sold independently.

---

### Noto Sans
**Source**: Google Fonts / Godot built-in
**License**: SIL Open Font License 1.1 (OFL)
**Copyright**: 2022 The Noto Project Authors

**OFL Compliance**: OFL.txt must be included with the build.

---

### Open Sans
**Source**: Google Fonts / Godot built-in
**License**: Apache License 2.0
**Copyright**: 2011 Google Inc.

**License Text**:
```
Apache License
Version 2.0, January 2004
http://www.apache.org/licenses/

Full license: https://www.apache.org/licenses/LICENSE-2.0
```

---

## Game Engine & Tools

### Godot Engine
**Source**: https://godotengine.org/
**Version**: 4.4.stable
**License**: MIT License
**Copyright**: 2007-2024 Juan Linietsky, Ariel Manzur and contributors

**License Text**:
```
MIT License

Copyright (c) 2007-2024 Juan Linietsky, Ariel Manzur and contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

### Godot Export Templates
**Source**: https://github.com/godotengine/godot-builds
**Version**: 4.4.stable
**License**: MIT License (same as Godot Engine)

---

## Reference Implementations (Code Study Only - Not Directly Copied)

### DiscoveringGodot/4_Heist_Meisters
**Source**: https://github.com/DiscoveringGodot/4_Heist_Meisters
**License**: Educational / Permissive (Course companion repo)
**Note**: Used for mechanics reference only. No code directly copied.

---

### godot-addons/godot-field-of-view
**Source**: https://github.com/godot-addons/godot-field-of-view
**License**: MIT License
**Note**: Referenced for FOV cone implementation patterns.

---

### obscura-tempura-studios/godot-4-stealth-skeleton
**Source**: itch.io
**License**: MIT License
**Note**: Referenced for patrol AI and vision system patterns.

---

## CI/CD Infrastructure

### GitHub Actions
**Source**: https://github.com/features/actions
**Terms**: GitHub Terms of Service

### actions/checkout
**Source**: https://github.com/actions/checkout
**License**: MIT License

### actions/setup-java
**Source**: https://github.com/actions/setup-java
**License**: MIT License

### android-actions/setup-android
**Source**: https://github.com/android-actions/setup-android
**License**: MIT License

### actions/cache
**Source**: https://github.com/actions/cache
**License**: MIT License

### actions/upload-artifact
**Source**: https://github.com/actions/upload-artifact
**License**: MIT License

---

## Compliance Notes

1. **CC0 Assets**: No attribution required, but credited here as best practice.
2. **OFL Fonts (Inter, JetBrains Mono, Noto Sans)**: 
   - OFL.txt included in build
   - Copyright notices preserved
   - Fonts not sold independently
   - Modified versions would use different names (not applicable)
3. **Apache 2.0 (Open Sans)**: License included, notices preserved.
4. **MIT Licenses (Godot, Reference Repos)**: License text included in distribution.
5. **No GPL or Copyleft Dependencies**: All dependencies are permissive or public domain.

---

## Distribution Checklist

When distributing the APK or game build:

- [ ] Include this THIRD_PARTY_NOTICES.md in the repository
- [ ] Include OFL.txt for each OFL font used (Inter, JetBrains Mono, Noto Sans)
- [ ] Preserve all copyright notices in font files
- [ ] Do not sell fonts independently
- [ ] MIT licenses (Godot) included in distribution
- [ ] Apache 2.0 license (Open Sans) included if used

---

*Generated for Stealth Game project - Phase B initialization*
*Last updated: 2026-10-22*