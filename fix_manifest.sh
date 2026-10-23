#!/bin/bash
# Fix AndroidManifest to remove adaptive icon references
# Usage: fix_manifest.sh <apk_path> <keystore_path>

set -e

APK_PATH="$1"
KEYSTORE_PATH="$2"

# Convert to absolute paths
APK_PATH=$(realpath "$APK_PATH")
KEYSTORE_PATH=$(realpath "$KEYSTORE_PATH")
WORKSPACE=$(pwd)

if [ ! -f "$APK_PATH" ]; then
    echo "Error: APK not found at $APK_PATH"
    exit 1
fi

if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "Error: Keystore not found at $KEYSTORE_PATH"
    exit 1
fi

echo "Fixing AndroidManifest.xml to remove adaptive icon references..."

# Create temp directory
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

# Copy APK and keystore to temp dir
cp "$APK_PATH" game.apk
cp "$KEYSTORE_PATH" debug.keystore

echo "Fixing AndroidManifest.xml to remove adaptive icon references..."

# Create minimal manifest without adaptive icons using Python
python3 -c "
import xml.etree.ElementTree as ET
ns = 'http://schemas.android.com/apk/res/android'
manifest = ET.Element('manifest', {
    'xmlns:android': 'http://schemas.android.com/apk/res/android',
    'package': 'com.example.stealthgame',
    'android:versionCode': '1',
    'android:versionName': '1.0.0',
    'android:installLocation': 'auto'
})
ET.SubElement(manifest, 'uses-sdk', {
    '{http://schemas.android.com/apk/res/android}minSdkVersion': '21',
    '{http://schemas.android.com/apk/res/android}targetSdkVersion': '34'
})
for feat in ['android.hardware.touchscreen', 'android.hardware.screen.portrait', 'android.hardware.screen.landscape']:
    ET.SubElement(manifest, 'uses-feature', {
        '{http://schemas.android.com/apk/res/android}name': feat,
        '{http://schemas.android.com/apk/res/android}required': 'false'
    })
application = ET.SubElement(manifest, 'application', {
    '{http://schemas.android.com/apk/res/android}label': 'Stealth Game',
    '{http://schemas.android.com/apk/res/android}icon': '@mipmap/icon',
    '{http://schemas.android.com/apk/res/android}debuggable': 'true',
    '{http://schemas.android.com/apk/res/android}allowBackup': 'false',
    '{http://schemas.android.com/apk/res/android}theme': '@android:style/Theme.NoTitleBar.Fullscreen',
    '{http://schemas.android.com/apk/res/android}hardwareAccelerated': 'true'
})
activity = ET.SubElement(manifest, 'activity', {
    '{http://schemas.android.com/apk/res/android}name': 'com.godot.GodotActivity',
    '{http://schemas.android.com/apk/res/android}label': 'Stealth Game',
    '{http://schemas.android.com/apk/res/android}configChanges': 'orientation|screenSize|keyboardHidden|navigation',
    '{http://schemas.android.com/apk/res/android}screenOrientation': 'sensorLandscape',
    '{http://schemas.android.com/apk/res/android}launchMode': 'singleTask',
    '{http://schemas.android.com/apk/res/android}windowSoftInputMode': 'adjustPan'
})
intent_filter = ET.SubElement(activity, 'intent-filter')
ET.SubElement(intent_filter, 'action', {'{http://schemas.android.com/apk/res/android}name': 'android.intent.action.MAIN'})
ET.SubElement(intent_filter, 'category', {'{http://schemas.android.com/apk/res/android}name': 'android.intent.category.LAUNCHER'})
ET.ElementTree(manifest).write('AndroidManifest.xml', encoding='utf-8', xml_declaration=True)
"

# Compile resources and link with aapt2
ANDROID_HOME="${ANDROID_HOME:-/usr/lib/android-sdk}"
BUILD_TOOLS="${ANDROID_HOME}/build-tools/34.0.0"

# Extract APK
unzip -oq game.apk -d apk_out

# Compile resources
aapt2 compile --dir apk_out/res -o compiled_resources.zip

# Link manifest and resources
aapt2 link \
  --manifest AndroidManifest.xml \
  -I /usr/lib/android-sdk/platforms/android-34/android.jar \
  -o fixed.apk \
  --java /dev/null \
  compiled_resources.zip

# Merge fixed manifest/resources back
unzip -oq fixed.apk -d fixed_out
cd apk_out
cp ../fixed_out/AndroidManifest.xml AndroidManifest.xml
cp -r ../fixed_out/res/* res/
cd ..

# Repackage
cd apk_out
zip -r0 ../game_fixed.apk .
cd ..

# Align and sign
zipalign -f -p 4 game_fixed.apk game_aligned.apk
apksigner sign \
  --ks debug.keystore \
  --ks-pass pass:android \
  --key-pass pass:android \
  --v1-signing-enabled true \
  --v2-signing-enabled true \
  --v3-signing-enabled true \
  --out game.apk \
  game_aligned.apk

# Copy fixed APK back to original location
cp game.apk "$WORKSPACE/build/game.apk"

# Cleanup
rm -rf apk_out fixed_out compiled_resources.zip fixed.apk game_fixed.apk game_aligned.apk AndroidManifest.xml game.apk debug.keystore

echo "Manifest fixed and APK repackaged"