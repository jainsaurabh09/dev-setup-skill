---
name: dev-setup
description: Set up a fresh Mac for app development from zero and walk the user all the way to publishing on the Apple App Store (and optionally Google Play). Installs and verifies Xcode Command Line Tools, Homebrew, Git, GitHub CLI, Node, Xcode, simulators, CocoaPods, Watchman, Flutter or Expo tooling, and fastlane, then guides Apple Developer enrollment, code signing, TestFlight and App Store submission. Use this skill whenever the user says they are new to Claude Code or app development, has a new/fresh machine, asks what to install to build an app, wants a "dev environment", "dev setup", "install everything I need", or asks how to get an app from idea to the App Store — even if they don't say "setup".
---

# Dev Setup: from a fresh Mac to the App Store

The user has probably just logged into Claude Code and wants to build an app and ship it. They may not be a developer. Your job is to get their machine ready, prove each tool works, and then guide them through the publishing steps, which they have to do themselves.

Work in phases. Finish and verify each phase before you start the next. Keep the user posted in plain language: say what you're installing and why, in one line each.

## Phase 0: Find out what they're building and check the machine

Ask these together, in one question round (use AskUserQuestion if it's available):

1. **Which app stack?**
   - *Native iOS (Swift/SwiftUI)*: best for iPhone-only apps. Needs only Xcode.
   - *React Native with Expo*: one JavaScript/TypeScript codebase for iOS and Android. Easiest for web developers.
   - *Flutter*: one Dart codebase for iOS and Android.
   - *Not sure*: recommend Expo for beginners who want both stores, and SwiftUI for iPhone only.
2. **Stores:** App Store only, or Google Play too? Android adds Android Studio and a JDK.
3. **Apple Developer account:** do they already have one? It costs US$99/year and is required to publish.

Then run the bundled checker to see what's already installed:

```bash
bash ~/.claude/skills/dev-setup/scripts/check_env.sh
```

It prints `OK` or `MISSING` for every tool. Skip anything that's already `OK`. If the machine isn't macOS, say that building and publishing iOS apps requires a Mac. Offer Android-only setup or a cloud build service (Expo EAS Build) instead.

**Look for an existing project first.** Check the working directory for `*.xcodeproj`, `*.xcworkspace`, `package.json` with `expo`, or `pubspec.yaml`. If one is there, the stack is already decided, so don't ask about it. In Phase 4, build *their* project instead of a hello-world app.

**The shell doesn't reload during the session.** Tools installed mid-session aren't on your Bash tool's PATH. Call them by full path (for example `/opt/homebrew/bin/gh`) or prefix commands with `eval "$(/opt/homebrew/bin/brew shellenv)" &&`. The checker script already adds the standard directories to its PATH.

## Phase 1: Core tools (every stack)

Some installers need the user's password (`sudo`) or a GUI click, and you can't type a password for them. Run `sudo -n true` first. If it says a password is required, hand that step to the user. They can type the command with a `!` prefix in the Claude Code prompt (for example `! sudo xcodebuild -license accept`) or run it in the macOS Terminal app, which is the more reliable choice when a password prompt is involved.

**Verify; don't trust "it's installed."** Users sometimes report success when the installer actually stopped at the "Press RETURN" or password prompt. Check that the file exists (for example `ls /opt/homebrew/bin/brew`) before moving on. If it's missing, tell them which prompts to watch for, suggest the Terminal app, and ask them to paste the last lines of output if it fails again.

| Tool | Why | Install |
|---|---|---|
| Xcode Command Line Tools | compilers and git | `xcode-select --install` (opens a GUI dialog: the user clicks Install) |
| Homebrew | package manager for everything else | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` (needs the password, so the user runs it) |
| Homebrew on PATH (Apple Silicon) | so `brew` is found | add `eval "$(/opt/homebrew/bin/brew shellenv)"` to **both** `~/.zprofile` and `~/.zshrc` (see below) |
| Git and GitHub CLI | version control and publishing code | `brew install git gh`, then the user runs `gh auth login` |
| A code editor | editing | VS Code: `brew install --cask visual-studio-code` (skip it if they already use one) |

**Put PATH lines in both `~/.zprofile` and `~/.zshrc`.** Only login shells read `.zprofile`, and VS Code terminals and some others skip it. That shows up as `zsh: command not found: gh` even though the tool is installed. Add each line only if it isn't already there:
```bash
for f in ~/.zprofile ~/.zshrc; do grep -q 'brew shellenv' "$f" 2>/dev/null || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$f"; done
grep -q '.local/bin' ~/.zshrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
zsh -i -c 'which brew gh'   # verify a fresh shell finds them
```
Then tell the user to run `source ~/.zshrc` or open a new terminal, because terminals that are already open won't pick up the change.

Install the rest of the Homebrew packages in one command, for example `brew install gh node cocoapods fastlane`. That's faster than one command per package and gives one log to read.

**Git identity:** ask for the name and email; don't guess them. Use AskUserQuestion with sensible suggestions: the macOS username for the name, the account email, or their GitHub noreply address. Then:
```bash
git config --global user.name "Their Name"
git config --global user.email "their@email"
git config --global init.defaultBranch main
```

**GitHub login:** `gh auth login` opens a browser, so the user runs it (choices: GitHub.com, HTTPS, Login with a web browser). Confirm it worked with `gh auth status`.

## Phase 2: Xcode (required for any iOS app)

Xcode is large (about 10–15 GB) and comes from Apple. Choose one route:
- **Mac App Store** (simplest): `open "macappstore://apps.apple.com/app/xcode/id497799835"`. The user clicks Get or Install.
- **xcodes CLI**: `brew install xcodesorg/made/xcodes aria2 && xcodes install --latest`. It asks for their Apple ID, so the user runs it.

When Xcode is installed:
```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer   # user runs (sudo)
sudo xcodebuild -license accept                                    # user runs (sudo)
xcodebuild -runFirstLaunch
xcodebuild -downloadPlatform iOS                                   # iOS simulator runtime
xcrun simctl list devices available | head                         # verify
```

## Phase 3: Stack-specific tools

Install only the section for the stack the user chose.

### Native iOS (Swift/SwiftUI)
Nothing more is required. Optional: `brew install swiftlint swiftformat`.

### React Native with Expo
```bash
brew install node watchman        # Node LTS and file watcher
brew install cocoapods            # iOS native dependencies
npm install -g eas-cli            # Expo build & submit service
node -v && npm -v && pod --version && eas --version
```
The user creates a free Expo account and runs `eas login`.

### Flutter
```bash
brew install --cask flutter
brew install cocoapods
flutter doctor
```
Fix every item `flutter doctor` flags for the platforms they chose. Ignore Android items if they're iOS-only.

### Android (only if they want Google Play)
```bash
brew install --cask android-studio
brew install --cask zulu@17       # JDK 17
```
The user opens Android Studio once and finishes the SDK setup wizard. Then add `ANDROID_HOME=$HOME/Library/Android/sdk`, and its `platform-tools` and `emulator` folders, to the PATH in `~/.zshrc`.

### Release automation (recommended for every stack)
```bash
brew install fastlane
```

## Phase 4: Prove it works by building and running an app

Build an app and run it in the iOS Simulator. A working build proves the toolchain end to end; a list of installed tools doesn't. Use the user's existing project if they have one; otherwise create a starter project in a folder they choose.

**SwiftUI / Xcode project.** This sequence was verified end to end:
```bash
xcodebuild -list -project App.xcodeproj                        # find the scheme
xcrun simctl list devices available | grep iPhone              # pick a device; prefer one already "(Booted)"
xcodebuild -project App.xcodeproj -scheme App \
  -destination 'id=<SIM_UDID>' -derivedDataPath build/DerivedData build \
  2>&1 | grep -E "error:|BUILD (SUCCEEDED|FAILED)"
APP=$(find build/DerivedData/Build/Products/Debug-iphonesimulator -maxdepth 1 -name "*.app" | head -1)
BID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$APP/Info.plist")
xcrun simctl boot <SIM_UDID> 2>/dev/null; xcrun simctl install <SIM_UDID> "$APP" && xcrun simctl launch <SIM_UDID> "$BID"
xcrun simctl io <SIM_UDID> screenshot <scratchpad>/sim.png     # then view it with the Read tool
```
Keep `build/` out of git by checking that it's in `.gitignore`. Check the screenshot yourself and describe what's on screen; that's the evidence the app runs. `open -a Simulator` may fail because the app's location varies between Xcode versions. That doesn't matter, since `simctl` works without the window. Tell the user they can see the app in Xcode with ⌘R.

- **Expo:** `npx create-expo-app@latest my-app && cd my-app && npx expo run:ios`
- **Flutter:** `flutter create my_app && cd my_app && flutter run`

Run `scripts/check_env.sh` once more and show the user the final summary.

## Phase 4b: Version control and GitHub

1. If the folder isn't a git repo, run `git init` and confirm that a `.gitignore` covers `build/`, `DerivedData/`, `xcuserdata/`, `*.xcuserstate` and `.DS_Store`. For Expo/Flutter it should also cover `node_modules/`, `.expo/`, `.dart_tool/` and `.env*`.
2. Stage the files, then **scan them for secrets** before committing: `git status --short | awk '{print $2}' | xargs grep -l -iE 'api[_-]?key|secret|password|token'`. Show the user any match and leave it out of the commit.
3. Make the first commit.
4. **Ask before creating a remote or pushing.** Default to a **private** repo unless the user says otherwise: `gh repo create <Name> --private --source=. --remote=origin --push`.
5. Give them the repo URL, the everyday `git add -A && git commit -m "…" && git push` routine, and the command to make the repo public later: `gh repo edit --visibility public --accept-visibility-change-consequences`.

## Phase 5: Road to the App Store (mostly the user's own actions)

These steps happen in Apple's portals under the user's own identity. Explain each one, give the link, and wait for them to confirm it's done. Don't enter their credentials or payment details, and don't submit anything for review without their explicit go-ahead. Details: `references/app-store-publishing.md`.

1. **Enroll** in the Apple Developer Program: https://developer.apple.com/programs/enroll/. Enrollment can take 24–48 hours to approve, so start it early.
2. **Sign in to Xcode** with that Apple ID: Xcode › Settings › Accounts. Turn on *Automatically manage signing* and pick the team.
3. **Choose a unique bundle ID** (for example `com.theirname.appname`) and set it in the project. Read the current one from the built app's `Info.plist` and tell the user what it is, since short IDs like `com.sj.App` may already be taken.
4. **Create the app record** in App Store Connect: https://appstoreconnect.apple.com › My Apps › +.
5. **Archive and upload a build:**
   - Xcode: Product › Archive › Distribute App › App Store Connect.
   - Expo: `eas build -p ios --profile production`, then `eas submit -p ios`.
   - Flutter: `flutter build ipa`, then upload with Xcode Organizer or `xcrun altool`/Transporter.
   - fastlane: `fastlane init`, then `fastlane beta` or `fastlane release`.
6. **Test it on TestFlight** on a real iPhone.
7. **Fill in the store listing:** screenshots (6.9" and 6.5" iPhone sizes at minimum), description, keywords, support URL, **privacy policy URL**, App Privacy answers, age rating, and pricing.
8. **Submit for review.** Review usually takes 1–3 days. If Apple rejects the app, read the reason with the user and fix it.

For Google Play, see the Android section of the reference file.

## Troubleshooting

- `command not found` right after an install: the PATH line is missing from `~/.zshrc` (it might only be in `~/.zprofile`), or the terminal hasn't reloaded it. Check with `ls /opt/homebrew/bin/<tool>`, fix `~/.zshrc`, then run `source ~/.zshrc` or open a new terminal. As a stopgap, run the tool by its full path.
- `claude: command not found` after installing Claude Code from the VS Code extension: the extension uses its own built-in copy, which isn't added to your shell. Install the CLI with `curl -fsSL https://claude.ai/install.sh | bash` and make sure `~/.local/bin` is on the PATH.
- Homebrew "installed" but `/opt/homebrew/bin/brew` doesn't exist: the installer stopped at a prompt. Rerun it in the Terminal app and watch for "Press RETURN" and "Password".
- `xcode-select: error: tool 'xcodebuild' requires Xcode`: the full Xcode isn't selected. Rerun the `xcode-select -s` step.
- CocoaPods errors on Apple Silicon: `brew reinstall cocoapods`, then `cd ios && pod install --repo-update`.
- Simulator missing: `xcodebuild -downloadPlatform iOS`.
- Signing errors ("No profiles for…"): the user isn't signed in to Xcode with a paid team, or the bundle ID is already taken.
