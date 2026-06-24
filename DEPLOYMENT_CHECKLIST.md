# Deployment Checklist

Use this checklist to ensure all features are properly deployed and tested.

## Pre-Deployment

### Code Review
- [x] All requested features implemented
- [x] No compilation errors
- [x] Code follows project conventions
- [x] Comments added where necessary
- [x] Documentation created

### Database Preparation
- [ ] Backup current database
- [ ] Review SQL migration script
- [ ] Test migration on staging database
- [ ] Verify `qr_image_url` column created

### Storage Setup
- [ ] Create `qr_codes` bucket in Supabase
- [ ] Set bucket to public
- [ ] Apply storage policies
- [ ] Test file upload/download
- [ ] Check storage quota

### Security
- [ ] Change default admin password
- [ ] Review admin authentication logic
- [ ] Consider implementing Supabase Auth
- [ ] Check Row Level Security policies
- [ ] Review file upload size limits

---

## Deployment Steps

### 1. Database Migration

```bash
# Run in Supabase SQL Editor
```

```sql
-- Step 1: Add new column
ALTER TABLE languages 
ADD COLUMN qr_image_url TEXT;

-- Step 2: Create index (optional, for performance)
CREATE INDEX idx_languages_qr_image ON languages(qr_image_url);

-- Step 3: Verify
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'languages' AND column_name = 'qr_image_url';
```

**Expected Result:** Should show `qr_image_url | text`

### 2. Storage Bucket Setup

#### Via Supabase Dashboard:
1. Go to Storage → Buckets
2. Click "New bucket"
3. Name: `qr_codes`
4. Public: ✅ Checked
5. Click "Create"

#### Apply Policies:

```sql
-- Public read access
CREATE POLICY "Public QR Code Access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'qr_codes');

-- Authenticated upload
CREATE POLICY "Authenticated QR Code Upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'qr_codes');

-- Authenticated delete
CREATE POLICY "Authenticated QR Code Delete"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'qr_codes');
```

### 3. Update Admin Password

Edit `lib/services/admin_service.dart`:

```dart
// Line 10: Change from 'admin123' to your secure password
static const String _defaultPassword = 'YOUR_SECURE_PASSWORD_HERE';
```

### 4. Build Application

```bash
# Clean build
flutter clean
flutter pub get

# Build for Android
flutter build apk --release

# Build for iOS (Mac only)
flutter build ios --release

# Build for web
flutter build web --release
```

### 5. Test Build

- [ ] Install release build on test device
- [ ] Verify app launches successfully
- [ ] Test all 5 new features
- [ ] Check for any runtime errors

---

## Post-Deployment Testing

### Feature 1: Admin Access Control

#### Test Cases:
- [ ] **Login with correct password**
  - Action: Tap person icon, enter correct password
  - Expected: Admin mode enabled, icon turns amber
  
- [ ] **Login with wrong password**
  - Action: Enter incorrect password
  - Expected: Error message shown
  
- [ ] **Admin mode persistence**
  - Action: Login, close app, reopen
  - Expected: Still in admin mode
  
- [ ] **Logout functionality**
  - Action: Tap admin icon when logged in
  - Expected: Admin mode disabled
  
- [ ] **Add button visibility**
  - Action: View screen as guest vs admin
  - Expected: Button only visible to admin

### Feature 2: Real-time Updates

#### Test Cases:
- [ ] **Pull-to-refresh**
  - Action: Swipe down on language list
  - Expected: Refresh animation, data updates
  
- [ ] **Auto-refresh after add**
  - Action: Add new language as admin
  - Expected: Returns to list with new language visible
  
- [ ] **Manual refresh button**
  - Action: Tap refresh icon in AppBar
  - Expected: List refreshes

### Feature 3: Image Format Support

#### Test Cases:
- [ ] **JPG upload**
  - Action: Select .jpg flag image
  - Expected: Uploads successfully
  
- [ ] **PNG upload**
  - Action: Select .png flag image
  - Expected: Uploads successfully
  
- [ ] **Other formats**
  - Action: Try GIF, WebP, BMP
  - Expected: All upload successfully
  
- [ ] **Image display**
  - Action: View uploaded images
  - Expected: Display correctly in app

### Feature 4: Edit & Delete

#### Test Cases:
- [ ] **Delete confirmation**
  - Action: Tap delete button (admin mode)
  - Expected: Confirmation dialog appears
  
- [ ] **Delete execution**
  - Action: Confirm deletion
  - Expected: Language removed from list
  
- [ ] **Delete refresh**
  - Action: After deletion
  - Expected: List automatically refreshes
  
- [ ] **Edit button**
  - Action: Tap edit button
  - Expected: "Coming soon" message
  
- [ ] **Admin-only visibility**
  - Action: View as guest
  - Expected: No edit/delete buttons visible

### Feature 5: QR Code Images

#### Test Cases:
- [ ] **Upload QR image**
  - Action: Select QR code image file
  - Expected: File selected, preview shown
  
- [ ] **QR image display**
  - Action: View language with QR image
  - Expected: QR displays in audio player
  
- [ ] **URL QR generation**
  - Action: Enter URL without image
  - Expected: QR code generated from URL
  
- [ ] **Mutual exclusivity**
  - Action: Select image
  - Expected: URL field disabled
  
- [ ] **Fallback behavior**
  - Action: Invalid image URL
  - Expected: Falls back to URL generation

---

## Performance Testing

### Load Testing
- [ ] Test with 50+ languages
- [ ] Verify scroll performance
- [ ] Check image loading speed
- [ ] Monitor memory usage

### Network Testing
- [ ] Test on slow connection
- [ ] Test offline mode
- [ ] Verify cached data works
- [ ] Check error handling

### Device Testing
- [ ] Test on small screen (phone)
- [ ] Test on large screen (tablet)
- [ ] Test on different OS versions
- [ ] Verify landscape mode

---

## Rollback Plan

### If Issues Found:

1. **Stop deployment immediately**
2. **Document the issue**
3. **Restore database backup if needed:**

```sql
-- Remove new column (if causing issues)
ALTER TABLE languages DROP COLUMN qr_image_url;
```

4. **Restore previous app version**
5. **Investigate and fix issues**
6. **Retry deployment**

---

## Monitoring

### After Deployment:

#### Day 1:
- [ ] Monitor error logs
- [ ] Check Supabase dashboard for errors
- [ ] Review user feedback
- [ ] Monitor storage usage
- [ ] Check database performance

#### Week 1:
- [ ] Analyze usage patterns
- [ ] Collect user feedback
- [ ] Identify any issues
- [ ] Plan improvements

#### Month 1:
- [ ] Review feature adoption
- [ ] Assess storage costs
- [ ] Plan edit screen implementation
- [ ] Consider Supabase Auth migration

---

## Success Criteria

### Feature Adoption:
- [ ] Admins can successfully login
- [ ] Languages being added with new features
- [ ] QR images being uploaded
- [ ] No critical errors reported
- [ ] Users satisfied with improvements

### Performance:
- [ ] App launch time unchanged
- [ ] Smooth scrolling maintained
- [ ] Image loading acceptable
- [ ] No memory leaks detected

### Stability:
- [ ] No crashes related to new features
- [ ] Error handling works correctly
- [ ] Offline mode still functional
- [ ] Data integrity maintained

---

## Support Plan

### User Support:
- [ ] Create user guide for admin features
- [ ] Train admins on new functionality
- [ ] Set up support channel
- [ ] Prepare FAQ document

### Technical Support:
- [ ] Monitor error logs daily
- [ ] Respond to issues within 24 hours
- [ ] Keep rollback plan ready
- [ ] Document all issues and solutions

---

## Documentation Delivered

1. ✅ `CHANGES_SUMMARY.md` - Quick overview of changes
2. ✅ `IMPLEMENTATION_UPDATES.md` - Detailed technical documentation
3. ✅ `SETUP_GUIDE.md` - Step-by-step setup instructions
4. ✅ `DEPLOYMENT_CHECKLIST.md` - This file

---

## Sign-off

### Pre-Deployment Approval:
- [ ] Code reviewed and approved
- [ ] Testing completed and passed
- [ ] Documentation reviewed
- [ ] Database backup confirmed
- [ ] Rollback plan verified

### Deployment Execution:
- [ ] Database migration successful
- [ ] Storage bucket created
- [ ] App deployed to production
- [ ] Basic smoke test passed
- [ ] Monitoring enabled

### Post-Deployment Verification:
- [ ] All features working in production
- [ ] No critical errors detected
- [ ] User feedback collected
- [ ] Performance acceptable
- [ ] Deployment successful ✅

---

**Deployment Date:** ___________________

**Deployed By:** ___________________

**Verified By:** ___________________

**Issues Found:** ___________________

**Resolution:** ___________________

---

## Emergency Contacts

- **Developer:** [Your contact]
- **DevOps:** [Contact]
- **Support:** [Contact]
- **Product Owner:** [Contact]

---

**Good luck with your deployment! 🚀**
