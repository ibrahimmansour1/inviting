# Setup Guide for New Features

## Quick Start

This guide will help you set up the new features: admin access control, image format support, QR image upload, and edit/delete functionality.

## Prerequisites

- Supabase project already configured
- Flutter app connected to Supabase
- Existing `languages` table

## Step-by-Step Setup

### 1. Database Schema Update

Run these SQL commands in your Supabase SQL Editor:

```sql
-- Add new column for QR code images
ALTER TABLE languages 
ADD COLUMN qr_image_url TEXT;

-- Optional: Add index for better performance
CREATE INDEX idx_languages_qr_image ON languages(qr_image_url);
```

### 2. Storage Bucket Setup

#### Create QR Codes Bucket:

1. Go to Supabase Dashboard → Storage
2. Click "Create bucket"
3. Name: `qr_codes`
4. Public: **Yes** (checked)
5. Click "Create bucket"

#### Set Storage Policies:

Run these SQL commands:

```sql
-- Allow public read access to QR codes
CREATE POLICY "Public QR Code Access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'qr_codes');

-- Allow authenticated users to upload QR codes
CREATE POLICY "Authenticated QR Code Upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'qr_codes');

-- Allow authenticated users to delete QR codes
CREATE POLICY "Authenticated QR Code Delete"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'qr_codes');
```

### 3. Test the Setup

#### Test Admin Login:
1. Run the app
2. On language selection screen, tap the person icon (top right)
3. Enter password: `admin123`
4. You should see admin mode enabled with amber icon

#### Test Image Upload:
1. Login as admin
2. Tap the "+" button
3. Select a flag image (any format: jpg, png, gif, etc.)
4. Verify it uploads successfully

#### Test QR Code:
1. In Add Language screen, scroll to "Additional Information"
2. Either enter a URL or upload a QR image
3. Add the language and verify QR displays in audio player

#### Test Delete:
1. Login as admin
2. Long-press or look for delete button (red) on a language card
3. Confirm deletion
4. Verify language is removed

### 4. Security Configuration (IMPORTANT)

#### Change Default Admin Password:

Edit `lib/services/admin_service.dart`:

```dart
// Change this line
static const String _defaultPassword = 'your_secure_password_here';
```

#### For Production (Recommended):

Replace client-side authentication with Supabase Auth:

1. Enable Supabase Auth in dashboard
2. Create `admin_users` table:

```sql
CREATE TABLE admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  role TEXT NOT NULL DEFAULT 'admin',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add your admin user
INSERT INTO admin_users (user_id, role)
VALUES ('YOUR_USER_ID', 'super_admin');
```

3. Update `AdminService` to check Supabase Auth

### 5. Verify All Features

- [ ] Can login as admin with password
- [ ] Admin icon shows in AppBar when logged in
- [ ] Add language button only visible to admins
- [ ] Can upload any image format for flags
- [ ] Can upload QR code images
- [ ] QR codes display correctly (both URL and image)
- [ ] Can delete languages with confirmation
- [ ] Delete refreshes list automatically
- [ ] Pull-to-refresh works on language list
- [ ] Edit button shows "coming soon" message

## Troubleshooting

### Issue: Admin password not working

**Solution:** 
- Check `lib/services/admin_service.dart` for current password
- Clear app data and try again
- Check console for any error messages

### Issue: QR images not displaying

**Solution:**
- Verify `qr_codes` bucket exists in Supabase Storage
- Check bucket is set to public
- Verify storage policies are applied
- Check browser console for CORS errors

### Issue: Cannot delete languages

**Solution:**
- Ensure you're logged in as admin
- Check internet connection
- Verify Supabase connection is working
- Check database permissions

### Issue: Images not uploading

**Solution:**
- Check storage quota in Supabase dashboard
- Verify bucket permissions
- Check file size (ensure it's under limit)
- Try with a smaller image file

### Issue: Pull-to-refresh not working

**Solution:**
- Swipe from the grid area (not AppBar)
- Ensure you're connected to internet
- Check if `RefreshIndicator` is properly wrapped

## Default Credentials

- **Admin Password:** `admin123` (change this in production!)
- **Supabase URL:** Check `lib/main.dart`
- **Supabase Anon Key:** Check `lib/main.dart`

## Storage Buckets Required

1. `flags` - For language flag images (should already exist)
2. `audios` - For audio files (should already exist)
3. `qr_codes` - For QR code images (NEW - create this)

## Database Tables

### Languages Table (Updated Schema)

```sql
CREATE TABLE languages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  native_name TEXT NOT NULL,
  flag_url TEXT NOT NULL,
  audio_url TEXT NOT NULL,
  qr_description TEXT,           -- QR URL/link
  qr_image_url TEXT,              -- NEW: QR code image URL
  motivational_text TEXT,
  person_num INTEGER,
  is_local BOOLEAN DEFAULT false,
  remote_audio_filename TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Production Checklist

Before deploying to production:

- [ ] Change admin password from default
- [ ] Set up proper Supabase Auth
- [ ] Configure Row Level Security (RLS) policies
- [ ] Add rate limiting for uploads
- [ ] Set storage size limits
- [ ] Enable backup for database
- [ ] Test all features in staging environment
- [ ] Update documentation with production credentials
- [ ] Set up monitoring and error tracking

## Support

For issues or questions:
1. Check `IMPLEMENTATION_UPDATES.md` for detailed information
2. Review Supabase logs in dashboard
3. Check Flutter console for error messages
4. Verify all SQL commands executed successfully

## Next Steps

1. Test all features thoroughly
2. Change default admin password
3. Consider implementing Supabase Auth for production
4. Build and deploy the app
5. Train users on new admin features

---

**Note:** This setup assumes you have an existing working Supabase configuration. If you're setting up from scratch, refer to the main `SUPABASE_SETUP.md` guide first.
