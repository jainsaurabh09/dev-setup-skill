# Publishing reference

## Apple App Store checklist

**Account**
- Apple Developer Program membership (US$99/yr): https://developer.apple.com/programs/enroll/
- Accept the latest agreements in App Store Connect › Business. Uploads fail silently while an agreement is pending.
- Paid apps and in-app purchases also need banking and tax forms (App Store Connect › Business).

**Project settings**
- Unique bundle identifier (reverse-DNS, e.g. `com.name.app`), registered automatically by Xcode's managed signing.
- Version (`CFBundleShortVersionString`, e.g. 1.0.0) and build number (`CFBundleVersion`). The build number must go up with every upload.
- App icon: a 1024×1024 PNG with no transparency.
- Every permission the app requests (camera, location, photos…) needs a usage description string in Info.plist, or the app is rejected.

**App Store Connect listing**
- Name (30 characters), subtitle (30), description, keywords (100), support URL, marketing URL (optional)
- Privacy policy URL (required for every app)
- App Privacy "nutrition label" questionnaire
- Screenshots: 6.9" iPhone (1320×2868) at minimum. Add iPad sizes if the app supports iPad.
- Age rating questionnaire, category, pricing and availability
- Review notes: a demo login if the app has accounts, plus an explanation of any non-obvious features

**Upload routes**
| Stack | Build | Upload |
|---|---|---|
| Xcode | Product › Archive | Organizer › Distribute App › App Store Connect |
| Expo | `eas build -p ios --profile production` | `eas submit -p ios --latest` |
| Flutter | `flutter build ipa --release` | open `build/ios/archive/*.xcarchive` in Organizer, or Transporter app |
| fastlane | `fastlane gym` | `fastlane pilot upload` (TestFlight) / `fastlane deliver` (store) |

**Common rejection reasons:** crashes or broken links (Guideline 2.1), a missing privacy policy, placeholder content, login required without a demo account, a missing "Delete account" option when the app offers account creation (5.1.1(v)), or the app being only a website wrapper (4.2).

## Google Play (optional)
1. Create a Google Play Console account (one-time US$25): https://play.google.com/console
2. New personal accounts must run a **closed test with at least 12 testers for 14 days** before production access.
3. Build an Android App Bundle (`.aab`):
   - Expo: `eas build -p android --profile production` → `eas submit -p android`
   - Flutter: `flutter build appbundle`
   - Native: Android Studio › Build › Generate Signed Bundle
4. Use Play App Signing. Keep the upload keystore backed up, because losing it blocks future updates.
5. Complete the store listing, Data safety form, content rating, target audience, and privacy policy, then roll out.
