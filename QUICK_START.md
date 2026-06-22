# Quick Start Guide - Call to Islam App

## 🚀 Getting Started (For Developers)

### Step 1: Install Dependencies
```bash
cd /path/to/inviting
flutter pub get
```

### Step 2: Setup Supabase Database

#### Option A: Using Supabase Dashboard
1. Go to your Supabase project: https://supabase.com/dashboard
2. Open SQL Editor
3. Copy and paste the SQL from `SUPABASE_SETUP.md`
4. Run all the SQL commands to create:
   - Tables: `languages`, `additional_sounds`, `books`, `videos`
   - Storage buckets: `flags`, `audios`, `books`, `videos`, `book_covers`, `video_thumbnails`
   - Row Level Security policies

#### Option B: Quick Setup Script
Create a file `setup_database.sql` and copy all SQL from `SUPABASE_SETUP.md`, then run:
```bash
# Using Supabase CLI (if installed)
supabase db push
```

### Step 3: Configure Storage Buckets
For each bucket (`flags`, `audios`, `books`, `videos`, `book_covers`, `video_thumbnails`):

1. Go to Storage in Supabase dashboard
2. Create bucket
3. Make it **public**
4. Set appropriate MIME types:
   - `flags`: `image/*`
   - `audios`: `audio/*`
   - `books`: `application/pdf, application/epub+zip`
   - `videos`: `video/*`
   - `book_covers`: `image/*`
   - `video_thumbnails`: `image/*`

### Step 4: Add Sample Data

#### Sample Language:
```sql
INSERT INTO languages (name, native_name, flag_url, audio_url, motivational_text, person_num, qr_description)
VALUES (
  'English',
  'English',
  'https://your-project.supabase.co/storage/v1/object/public/flags/english_flag.png',
  'https://your-project.supabase.co/storage/v1/object/public/audios/english_audio.mp3',
  '+1234567890 Learn more about Islam and connect with us!',
  1234567890,
  'https://example.com/english-resources'
);
```

#### Sample Book:
```sql
INSERT INTO books (language_id, title, description, file_url, cover_image_url, shareable_link)
VALUES (
  'your-language-id-here',
  'Introduction to Islam',
  'A comprehensive guide to understanding Islamic teachings',
  'https://your-project.supabase.co/storage/v1/object/public/books/intro_islam.pdf',
  'https://your-project.supabase.co/storage/v1/object/public/book_covers/intro_islam_cover.jpg',
  'https://example.com/books/intro-islam'
);
```

#### Sample Video:
```sql
INSERT INTO videos (language_id, title, description, video_url, thumbnail_url, shareable_link, duration_seconds)
VALUES (
  'your-language-id-here',
  'The Five Pillars of Islam',
  'Learn about the fundamental practices of Islam',
  'https://your-project.supabase.co/storage/v1/object/public/videos/five_pillars.mp4',
  'https://your-project.supabase.co/storage/v1/object/public/video_thumbnails/five_pillars_thumb.jpg',
  'https://example.com/videos/five-pillars',
  600
);
```

### Step 5: Run the App
```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android

# For Web
flutter run -d chrome

# Or let Flutter choose
flutter run
```

## 📱 Testing the Features

### ✅ Audio Features
1. **Main Audio**: Select a language → Audio should auto-play
2. **Additional Sounds**: Tap "Additional Sounds" button → List appears → Play any sound
3. **Share Audio**: Tap share icon → Native share dialog appears → Share works

### ✅ Books Features
1. **View Books**: Open language → Tap "Books" button → List of books appears
2. **Read Book**: Tap "Read Book" → Opens in external viewer
3. **Share Book**: Tap share icon → Native share dialog appears
4. **QR Code**: Tap QR icon → QR code appears in modal

### ✅ Videos Features
1. **View Videos**: Open language → Tap "Videos" button → List of videos appears
2. **Play Video**: Tap video or "Watch" button → Custom player opens
3. **Control Video**: Play/pause, seek using progress bar
4. **Share Video**: Tap share icon → Native share dialog appears
5. **QR Code**: Tap QR icon → QR code appears in modal

### ✅ Other Features
1. **WhatsApp**: Scroll to "Connect & Share" → Tap WhatsApp button → Opens WhatsApp
2. **Motivational Text**: Should appear in player screen if available
3. **QR Code**: Should appear in "Connect & Share" if `qr_description` is set
4. **Search**: Type in search box on language selection screen
5. **Offline**: Turn off internet → App should show cached data

## 🌍 Localization Testing

### Test Language Switching:
1. **iOS**: Settings → General → Language & Region → iPhone Language
2. **Android**: Settings → System → Languages & input → Languages

Supported languages:
- **English** (en) - Default
- **Arabic** (ar) - With RTL support

## 🐛 Troubleshooting

### Build Issues:

#### Problem: "Target of URI doesn't exist: supabase_flutter"
**Solution**:
```bash
flutter clean
flutter pub get
```

#### Problem: "Localization files not found"
**Solution**:
```bash
flutter gen-l10n
flutter pub get
```

#### Problem: "No languages appear"
**Solution**:
1. Check internet connection
2. Verify Supabase URL and anon key in `lib/main.dart`
3. Verify database tables exist
4. Check Supabase RLS policies allow public read

### Runtime Issues:

#### Problem: Audio doesn't play
**Solution**:
1. Verify audio URL is accessible
2. Check file format is supported (MP3, WAV, AAC)
3. Verify storage bucket `audios` is public

#### Problem: Books don't open
**Solution**:
1. Verify PDF URL is accessible
2. Check storage bucket `books` is public
3. Verify device has PDF reader installed

#### Problem: Videos don't play
**Solution**:
1. Verify video URL is accessible
2. Check video format (MP4 recommended)
3. Verify storage bucket `videos` is public
4. Check internet connection speed

#### Problem: WhatsApp doesn't open
**Solution**:
1. Verify WhatsApp is installed on device
2. Check phone number format: `+1234567890`
3. Verify `person_num` or `motivational_text` contains valid phone number

## 📊 Database Management

### View Data:
```sql
-- Get all languages
SELECT * FROM languages;

-- Get languages with counts
SELECT 
  l.*,
  COUNT(DISTINCT as.id) as additional_sounds_count,
  COUNT(DISTINCT b.id) as books_count,
  COUNT(DISTINCT v.id) as videos_count
FROM languages l
LEFT JOIN additional_sounds as ON as.language_id = l.id
LEFT JOIN books b ON b.language_id = l.id
LEFT JOIN videos v ON v.language_id = l.id
GROUP BY l.id;
```

### Add New Language:
```sql
-- 1. First upload flag and audio to storage buckets
-- 2. Then insert language
INSERT INTO languages (name, native_name, flag_url, audio_url)
VALUES ('French', 'Français', 'flag_url_here', 'audio_url_here');
```

### Add Additional Sound:
```sql
INSERT INTO additional_sounds (language_id, name, file_url)
VALUES ('language-id-here', 'Prayer Audio', 'audio_url_here');
```

### Add Book:
```sql
INSERT INTO books (language_id, title, description, file_url, cover_image_url)
VALUES ('language-id-here', 'Book Title', 'Description', 'pdf_url', 'cover_url');
```

### Add Video:
```sql
INSERT INTO videos (language_id, title, description, video_url, thumbnail_url, duration_seconds)
VALUES ('language-id-here', 'Video Title', 'Description', 'video_url', 'thumb_url', 600);
```

## 🎯 Production Deployment

### iOS App Store:

1. **Update Version**:
   ```yaml
   # pubspec.yaml
   version: 1.0.6+6  # Increment version
   ```

2. **Build**:
   ```bash
   flutter build ios --release
   ```

3. **Archive in Xcode**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Product → Archive
   - Upload to App Store Connect

### Android Play Store:

1. **Update Version**:
   ```yaml
   # pubspec.yaml
   version: 1.0.6+6  # Increment version
   ```

2. **Build**:
   ```bash
   flutter build appbundle --release
   ```

3. **Upload**:
   - Go to Play Console
   - Upload `build/app/outputs/bundle/release/app-release.aab`

### Web Deployment:

```bash
flutter build web --release
# Deploy contents of build/web/ to your hosting
```

## 📞 Support

### For Issues:
1. Check `IMPLEMENTATION_SUMMARY.md` for detailed documentation
2. Check `FEATURES.md` for feature-specific help
3. Check `SUPABASE_SETUP.md` for database issues
4. Review Flutter and Supabase documentation

### Common Resources:
- Flutter Docs: https://flutter.dev/docs
- Supabase Docs: https://supabase.com/docs
- Video Player: https://pub.dev/packages/video_player
- QR Flutter: https://pub.dev/packages/qr_flutter

## ✅ Pre-Launch Checklist

- [ ] Database tables created
- [ ] Storage buckets configured
- [ ] At least 3 sample languages added
- [ ] Sample books added
- [ ] Sample videos added
- [ ] Tested on iOS device
- [ ] Tested on Android device
- [ ] Audio playback works
- [ ] Books open correctly
- [ ] Videos play correctly
- [ ] WhatsApp integration works
- [ ] Sharing works
- [ ] QR codes generate
- [ ] Offline mode works
- [ ] Search works
- [ ] Localization tested (EN/AR)
- [ ] App icons updated
- [ ] Version number incremented
- [ ] Release notes prepared

## 🎉 You're Ready!

Your app is now fully functional with all requested features:
- ✅ Multiple sub-audios per language
- ✅ Audio sharing with custom messages
- ✅ Books feature with PDF support and sharing
- ✅ QR code generation for easy mobile sharing
- ✅ Link sharing for all content types
- ✅ Motivational texts with WhatsApp integration
- ✅ Video section with custom player
- ✅ WhatsApp contact buttons
- ✅ Multi-language support (EN/AR)
- ✅ Background audio playback (with wakelock)

**Next**: Add your content to Supabase and start testing! 🚀
