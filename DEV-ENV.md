# Divine Light — Development Environment Setup

This guide walks through setting up the full development environment for Divine Light on Windows. Complete each step in order — each one builds on the last.

## What We're Installing

| Tool | Purpose |
|---|---|
| **Godot 4** (Standard) | Game engine — where the game is built |
| **OpenJDK 17** | Java runtime — required by the Android SDK |
| **Android Studio** | Easiest way to install and manage the Android SDK |
| **Godot Android Export Templates** | Lets Godot build APK files for the RP6 |
| **VS Code — Godot Tools extension** | GDScript syntax, autocomplete, and debugging in VS Code |

---

## Step 1 — Install Godot 4

1. Go to **godotengine.org** and download **Godot Engine 4.x — Standard** (Windows 64-bit)
   - Pick **Standard**, not the .NET version — this project uses GDScript, not C#
2. Extract the zip to a permanent location (e.g. `C:\Godot\`)
3. Run `Godot_v4.x.exe` — no installer needed, it runs directly
4. The Project Manager will open — leave it for now

---

## Step 2 — Install OpenJDK 17

> **Why 17 and not the latest?** Godot 4's Android export uses Gradle internally, and Gradle is tightly coupled to specific Java versions. Godot 4 was designed and tested against JDK 17. Using a newer version (21, 25, etc.) can cause Gradle compatibility errors during APK builds. Always use the version the engine specifies, not the latest available.

1. Go to **adoptium.net** and download **Temurin 17 LTS** for Windows x64
   - If the front page shows a newer version, click **Other platforms and versions** and select **Version: 17**
2. Run the installer using all defaults
3. Verify the install — open a new PowerShell window and run:
   ```
   java -version
   ```
   Expected output: `openjdk version "17.x.x"`

---

## Step 3 — Install Android Studio

Android Studio is used here purely to install and manage the Android SDK. You will not use it as your IDE.

1. Go to **developer.android.com/studio** and download Android Studio
2. Run the installer using all defaults
3. On first launch, the setup wizard runs automatically:
   - Choose **Standard** installation
   - Let it download the Android SDK (takes a few minutes)
4. Once complete, locate and copy your SDK path — you will need it in Step 5:
   - In Android Studio: **File > Settings > Appearance & Behavior > System Settings > Android SDK**
   - Copy the **Android SDK Location** path (typically `C:\Users\YourName\AppData\Local\Android\Sdk`)

---

## Step 4 — Install Android NDK and API 33

Still inside Android Studio:

1. Go to **File > Settings > Appearance & Behavior > System Settings > Android SDK**
2. **SDK Platforms tab** — check **Android 13 (API 33)**
3. **SDK Tools tab** — check the following:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - NDK (Side by side)
4. Click **Apply** and let everything download

---

## Step 5 — Connect Godot to the Android SDK

The most reliable approach is setting the `ANDROID_HOME` environment variable — Godot detects it automatically on startup.

1. Open PowerShell and run:
   ```
   [System.Environment]::SetEnvironmentVariable("ANDROID_HOME", "$env:LOCALAPPDATA\Android\Sdk", "User")
   ```
2. Close Godot completely and reopen it — it will detect the SDK automatically

**Verifying manually in Godot (optional):**
- Go to **Editor > Editor Settings**
- In the left panel tree, navigate to **Export > Android** (do not use the search bar — navigate the tree directly)
- Confirm **Android Sdk Path** and **Java Sdk Path** are populated
- Note: The Export > Android section only appears after export templates are installed (Step 6)

---

## Step 6 — Download Godot Export Templates

Export templates are required to build APK files.

1. In Godot, go to **Editor > Manage Export Templates**
2. Click **Download and Install**
3. Godot will download the templates matching your installed version automatically

---

## Step 7 — Configure VS Code with Godot Tools

1. Open VS Code
2. Open **Extensions** (Ctrl+Shift+X)
3. Search for **godot-tools** by **geequlim** and install it
4. Back in Godot, go to **Editor > Editor Settings**
5. Search for `external editor`
6. Set **Text Editor > External > Use External Editor** to **ON**
7. Set the executable path to your VS Code binary:
   ```
   C:\Users\YourName\AppData\Local\Programs\Microsoft VS Code\Code.exe
   ```
8. Double-clicking any GDScript file in Godot will now open it in VS Code

---

## Step 8 — Enable USB Debugging on the Retroid Pocket 6

Direct USB deployment lets you test builds on the device instantly.

1. On the RP6: **Settings > About Phone**
   - Tap **Build Number** 7 times to unlock Developer Options
2. Go to **Settings > Developer Options**
   - Enable **USB Debugging**
3. Connect the RP6 to your PC via USB
4. A prompt appears on the RP6 — tap **Allow**
5. Verify the connection — open PowerShell and run:
   ```
   adb devices
   ```
   Your RP6 should appear in the list

---

## Verification Checklist

Before starting development, confirm each of the following:

- [ ] `java -version` returns OpenJDK 17 in PowerShell
- [ ] Godot Editor Settings shows a valid Android SDK path with no errors
- [ ] Godot Export Templates are installed (Editor > Manage Export Templates shows green)
- [ ] VS Code opens when double-clicking a GDScript file from Godot
- [ ] `adb devices` lists the RP6 when connected via USB

---

## Troubleshooting

**Godot can't find the Android SDK**
Confirm the path in Editor Settings matches the exact folder containing the `platforms/` and `tools/` subdirectories.

**`java -version` not found after install**
Close and reopen PowerShell — the PATH update from the JDK installer requires a fresh shell session.

**RP6 not showing in `adb devices`**
- Make sure USB Debugging is enabled on the RP6
- Try a different USB cable — some cables are charge-only
- On the RP6, check for the "Allow USB Debugging" prompt and tap Allow

**Godot Tools extension not connecting to Godot**
- Ensure Godot is running before opening a GDScript file in VS Code
- Check that the language server port in both Godot and the extension settings match (default: 6005)
