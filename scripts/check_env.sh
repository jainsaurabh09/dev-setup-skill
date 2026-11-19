#!/usr/bin/env bash
# Reports which app-development tools are installed. Read-only: installs nothing.

ok()   { printf "  \033[32mOK\033[0m       %-26s %s\n" "$1" "$2"; }
miss() { printf "  \033[31mMISSING\033[0m  %-26s %s\n" "$1" "$2"; }

check_cmd() { # name, command, version-args
  if command -v "$2" >/dev/null 2>&1; then
    ok "$1" "$("$2" $3 2>&1 | head -1)"
  else
    miss "$1" "($2 not on PATH)"
  fi
}

# Include standard install dirs so tools installed this session are found even before the shell reloads.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

echo "System: $(sw_vers -productName 2>/dev/null || uname -s) $(sw_vers -productVersion 2>/dev/null) ($(uname -m))"
[ "$(uname -s)" = "Darwin" ] || echo "  NOTE: iOS builds require macOS."
echo

echo "Core"
if xcode-select -p >/dev/null 2>&1; then ok "Xcode CLT / dev dir" "$(xcode-select -p)"; else miss "Xcode Command Line Tools" "run: xcode-select --install"; fi
check_cmd "Homebrew" brew --version
check_cmd "Git" git --version
check_cmd "GitHub CLI" gh --version
check_cmd "Claude Code" claude --version
git config --global user.name >/dev/null 2>&1 && ok "git identity" "$(git config --global user.name)" || miss "git identity" "git config --global user.name/email"

echo; echo "Xcode / iOS"
if [ -d /Applications/Xcode.app ]; then
  ok "Xcode.app" "$(xcodebuild -version 2>/dev/null | head -1)"
  case "$(xcode-select -p 2>/dev/null)" in
    *Xcode.app*) ok "xcode-select -> Xcode" "" ;;
    *) miss "xcode-select -> Xcode" "sudo xcode-select -s /Applications/Xcode.app/Contents/Developer" ;;
  esac
  n=$(xcrun simctl list devices available 2>/dev/null | grep -c "iPhone")
  [ "${n:-0}" -gt 0 ] && ok "iOS simulators" "$n iPhone devices" || miss "iOS simulators" "xcodebuild -downloadPlatform iOS"
else
  miss "Xcode.app" "install from the Mac App Store"
fi
check_cmd "CocoaPods" pod --version
check_cmd "fastlane" fastlane --version

echo; echo "Cross-platform (only needed for that stack)"
check_cmd "Node.js" node -v
check_cmd "npm" npm -v
check_cmd "Watchman" watchman --version
check_cmd "EAS CLI (Expo)" eas --version
check_cmd "Flutter" flutter --version

echo; echo "Android (only if publishing to Google Play)"
if /usr/libexec/java_home >/dev/null 2>&1; then ok "Java (JDK)" "$(/usr/libexec/java_home)"; else miss "Java (JDK)" "brew install --cask zulu@17"; fi
[ -d "/Applications/Android Studio.app" ] && ok "Android Studio" "" || miss "Android Studio" "brew install --cask android-studio"
[ -n "$ANDROID_HOME" ] && ok "ANDROID_HOME" "$ANDROID_HOME" || miss "ANDROID_HOME" "export ANDROID_HOME=\$HOME/Library/Android/sdk"
check_cmd "adb" adb --version
