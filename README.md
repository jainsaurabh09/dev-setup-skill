# dev-setup: what to install, in order

This is a reference list for setting up a Mac to build an iPhone app and publish it to the App Store. Install things **in this order**, because later steps depend on earlier ones. For example, Homebrew needs the Command Line Tools, and most other tools need Homebrew.

To have Claude do this for you, type `/dev-setup` in Claude Code.
To see what's already installed: `bash ~/.claude/skills/dev-setup/scripts/check_env.sh`

**Who runs it:** 🤖 = Claude can run it. 👤 = you run it yourself, because it needs your password, Apple ID, a browser sign-in or a click.
To run a 👤 step, type it in the Claude Code prompt with a `!` in front, or use the macOS **Terminal** app (the more reliable option when a password is needed).

---

## Stage 1: Required for every app

| # | Tool | Why you need it | Install command | Who | Check it worked |
|---|---|---|---|---|---|
| 1 | **Claude Code CLI** | Lets you run `claude` in any terminal (the VS Code extension's copy doesn't do this) | `curl -fsSL https://claude.ai/install.sh \| bash` | 🤖 | `claude --version` |
| 2 | **Xcode Command Line Tools** | Compilers and `git`; Homebrew needs them | `xcode-select --install`, then click **Install** | 👤 | `xcode-select -p` |
| 3 | **Homebrew** | Installs almost everything else | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` | 👤 password | `ls /opt/homebrew/bin/brew` |
| 4 | **PATH setup** | Lets every terminal find `claude`, `brew` and the tools installed with Homebrew | see [PATH setup](#path-setup) below | 🤖 | open a new terminal, then `which brew gh` |
| 5 | **Git identity** | Puts your name on your commits | `git config --global user.name "Your Name"`<br>`git config --global user.email "you@example.com"`<br>`git config --global init.defaultBranch main` | 🤖 | `git config --global --list` |
| 6 | **GitHub CLI** (`gh`) | Creates repos and pushes code to GitHub | `brew install gh` | 🤖 | `gh --version` |
| 7 | **GitHub login** | Connects `gh` to your GitHub account | `gh auth login` (GitHub.com, then HTTPS, then Login with a web browser) | 👤 browser | `gh auth status` |
| 8 | **Code editor** (optional) | For editing code; skip it if you already have one | `brew install --cask visual-studio-code` | 🤖 | opens from Applications |

## Stage 2: Xcode, required for any iOS app

| # | Tool | Why you need it | Install command | Who | Check it worked |
|---|---|---|---|---|---|
| 9 | **Xcode** (~10–15 GB) | Builds, signs and uploads iOS apps | Mac App Store: `open "macappstore://apps.apple.com/app/xcode/id497799835"` | 👤 Apple ID | `xcodebuild -version` |
| 10 | **Select Xcode** | Points the command-line tools at the full Xcode | `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` | 👤 password | `xcode-select -p` shows `Xcode.app` |
| 11 | **Accept the Xcode license** | Xcode won't build until you accept it | `sudo xcodebuild -license accept` | 👤 password | no error |
| 12 | **First-launch components** | Extra parts Xcode needs before its first build | `xcodebuild -runFirstLaunch` | 🤖 | no error |
| 13 | **iOS Simulator runtime** | Runs your app on a virtual iPhone | `xcodebuild -downloadPlatform iOS` | 🤖 | `xcrun simctl list devices available` |

## Stage 3: Install the tools for your app type

Pick **one** of these sections.

### A. Native iOS (Swift / SwiftUI)
No extra tools are needed. Optional: `brew install swiftlint swiftformat` (code style checkers).

### B. React Native with Expo (iOS and Android from one codebase)
| # | Tool | Why you need it | Install command | Who | Check it worked |
|---|---|---|---|---|---|
| 14 | **Node.js and npm** | Runs JavaScript tooling | `brew install node` | 🤖 | `node -v` |
| 15 | **Watchman** | Watches files so changes reload quickly | `brew install watchman` | 🤖 | `watchman --version` |
| 16 | **CocoaPods** | Installs iOS libraries | `brew install cocoapods` | 🤖 | `pod --version` |
| 17 | **EAS CLI** | Expo's cloud build and submit tool | `npm install -g eas-cli` | 🤖 | `eas --version` |
| 18 | **Expo login** | Connects EAS to your Expo account (free) | `eas login` | 👤 | `eas whoami` |

### C. Flutter (iOS and Android from one codebase)
| # | Tool | Why you need it | Install command | Who | Check it worked |
|---|---|---|---|---|---|
| 14 | **Flutter SDK** | The Flutter framework and command-line tools | `brew install --cask flutter` | 🤖 | `flutter --version` |
| 15 | **CocoaPods** | Installs iOS libraries | `brew install cocoapods` | 🤖 | `pod --version` |
| 16 | **Flutter doctor** | Lists anything still missing | `flutter doctor` | 🤖 | all ✓ for iOS |

## Stage 4: Release tools (recommended)

| # | Tool | Why you need it | Install command | Who | Check it worked |
|---|---|---|---|---|---|
| 19 | **fastlane** | Automates screenshots, builds and App Store uploads | `brew install fastlane` | 🤖 | `fastlane --version` |

## Stage 5: Only if you also publish to Google Play

| # | Tool | Why you need it | Install command | Who | Check it worked |
|---|---|---|---|---|---|
| 20 | **JDK 17** | Android builds need Java | `brew install --cask zulu@17` | 🤖 | `/usr/libexec/java_home` |
| 21 | **Android Studio** | The Android SDK and emulator | `brew install --cask android-studio`, then open it once and finish the setup wizard | 👤 | app opens |
| 22 | **Android PATH setup** | Lets the terminal find `adb` and the emulator | add to `~/.zshrc`:<br>`export ANDROID_HOME=$HOME/Library/Android/sdk`<br>`export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"` | 🤖 | `adb --version` |

## Stage 6: Accounts you need to publish

None of these is software, but you need them before your app can go live. All of them are 👤: they're tied to your identity and payment.

| # | Account | Cost | Link | Notes |
|---|---|---|---|---|
| 23 | **Apple Developer Program** | US$99/year | https://developer.apple.com/programs/enroll/ | Approval can take 24–48 hours, so start early |
| 24 | **Sign in to Xcode** | none | Xcode › Settings › Accounts | Turn on *Automatically manage signing* |
| 25 | **App Store Connect** | included | https://appstoreconnect.apple.com | Create the app record, accept the agreements, and add tax and banking details for paid apps |
| 26 | **Google Play Console** (optional) | US$25 once | https://play.google.com/console | New accounts need 12 testers for 14 days before going live |

---

## PATH setup

Only login shells read `~/.zprofile`, and VS Code terminals skip it. If your tools are set up only there, you'll see `command not found` even though they're installed. Put the lines in **both** files:

```bash
for f in ~/.zprofile ~/.zshrc; do
  grep -q 'brew shellenv' "$f" 2>/dev/null || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$f"
done
grep -q '.local/bin' ~/.zshrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Terminals that are already open won't see the change. Run `source ~/.zshrc` in each one, or open a new terminal.

## One-line install (after step 3)

Native iOS:
```bash
brew install gh cocoapods fastlane
```
Expo:
```bash
brew install gh node watchman cocoapods fastlane && npm install -g eas-cli
```
Flutter:
```bash
brew install gh cocoapods fastlane && brew install --cask flutter
```

## After installing

1. **Prove it works:** build your app and run it in the simulator (in Xcode, press ⌘R).
2. **Save it to GitHub:** `git init`, make a commit, then `gh repo create <Name> --private --source=. --remote=origin --push`.
3. **Publish:** archive the app, upload it to TestFlight, test it, fill in the store listing (screenshots and a privacy policy URL are required), then submit for review. See [references/app-store-publishing.md](references/app-store-publishing.md) for details.

## Common problems

| Symptom | Fix |
|---|---|
| `command not found: gh` (or `brew`, `node`…) | Do the [PATH setup](#path-setup), then open a new terminal |
| `command not found: claude` | Install step 1. The VS Code extension doesn't add `claude` to your terminal |
| Homebrew says it installed, but `/opt/homebrew/bin/brew` is missing | The installer stopped at a prompt. Rerun it in the Terminal app and press Enter or type your password when asked |
| `xcodebuild requires Xcode` | Do step 10 |
| No simulators | Do step 13 |
| Signing error "No profiles for…" | Sign in to Xcode with a paid developer account (step 24), or change the bundle ID |
