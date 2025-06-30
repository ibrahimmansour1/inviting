# Google Play Store Upload Guide for Call to islam App

## 🔐 Step 1: Update Keystore Configuration

You need to update the `/Users/ibrahim/Documents/contributions/call_to_islam/android/key.properties` file with the actual passwords you used when creating the keystore.

**IMPORTANT**: Replace the placeholder values in `android/key.properties`:

```
storePassword=YOUR_ACTUAL_KEYSTORE_PASSWORD
keyPassword=YOUR_ACTUAL_KEY_PASSWORD
keyAlias=upload
storeFile=../../../upload-keystore.jks
```

Replace `YOUR_ACTUAL_KEYSTORE_PASSWORD` and `YOUR_ACTUAL_KEY_PASSWORD` with the passwords you entered when the keystore was created.

## 📱 Step 2: Build the App Bundle

After updating the passwords, run:

```bash
flutter build appbundle --release
```

This will create the `.aab` file at: `build/app/outputs/bundle/release/app-release.aab`

## 🏪 Step 3: Google Play Console Setup

1. **Create Google Play Developer Account**

   - Go to https://play.google.com/console
   - Pay the one-time $25 registration fee
   - Complete account verification

2. **Create New App**

   - Click "Create app"
   - Fill in app details:
     - App name: "Call to islam"
     - Default language: Choose your preferred language
     - App or game: App
     - Free or paid: Choose based on your monetization strategy

3. **Complete App Information**
   - **App content**: Complete all required sections
   - **Privacy Policy**: Required for apps that handle user data
   - **Target audience**: Set age ratings
   - **Content rating**: Complete questionnaire
   - **App access**: Specify if app has restricted access

## 📋 Step 4: Store Listing

### Required Assets:

- **App icon**: ✅ Already configured (512x512 PNG)
- **Feature graphic**: 1024x500 PNG
- **Screenshots**: At least 2 phone screenshots (16:9 or 9:16 aspect ratio)
- **Short description**: Max 80 characters
- **Full description**: Max 4000 characters

### Store Listing Content Suggestions:

**Short Description:**
"Learn languages with native audio pronunciation and interactive exercises."

**Full Description:**
"Call to islam is an interactive language learning app that helps you master pronunciation with native speaker audio. Perfect for beginners and advanced learners alike.

Features:
• Native speaker audio for authentic pronunciation
• Multiple language support with flag recognition
• Interactive learning exercises
• Clean, user-friendly interface
• Offline audio playback capability

Whether you're preparing for travel, business, or personal enrichment, Call to islam makes language learning engaging and effective."

## 🚀 Step 5: Release Management

1. **Upload App Bundle**

   - Go to "Release" → "Production"
   - Upload your `app-release.aab` file
   - Add release notes

2. **Review and Publish**
   - Complete all required sections
   - Submit for review (usually takes 1-3 days)

## 🔧 Current App Configuration

- **Package Name**: `com.calltoislam.app`
- **Version**: 1.0.0+1
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: Latest Flutter target
- **Permissions**: INTERNET (for audio downloads)

## 📝 Additional Recommendations

1. **Create Screenshots**: Use an Android emulator or device to take appealing screenshots
2. **Privacy Policy**: If your app collects any user data, create a privacy policy
3. **App Icon**: Your custom icon is already configured ✅
4. **Testing**: Test thoroughly on different devices before uploading

## 🛠️ Commands to Remember

```bash
# Build release APK for testing
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Install release APK on device for testing
flutter install --release
```

## 📁 Important Files Created/Modified

- ✅ `android/key.properties` - Keystore configuration
- ✅ `android/app/build.gradle` - Build configuration with signing
- ✅ `pubspec.yaml` - App metadata and launcher icons
- ✅ `~/upload-keystore.jks` - Signing keystore (keep this safe!)

**⚠️ SECURITY NOTE**:

- Never commit `key.properties` or keystore files to version control
- Back up your keystore file securely - losing it means you can't update your app
- Keep passwords secure and don't share them

---

Once you update the passwords in `key.properties`, the build should succeed and you'll have your `.aab` file ready for Google Play Store upload!
