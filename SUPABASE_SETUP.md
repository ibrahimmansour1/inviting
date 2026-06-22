# Supabase Database Setup Guide

## Required Tables

### 1. Languages Table
```sql
CREATE TABLE languages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  native_name TEXT NOT NULL,
  flag_url TEXT NOT NULL,
  audio_url TEXT NOT NULL,
  remote_audio_filename TEXT,
  motivational_text TEXT,
  person_num INTEGER,
  qr_description TEXT,
  is_local BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE languages ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read access" ON languages
  FOR SELECT USING (true);

-- Allow authenticated insert/update/delete (for admin)
CREATE POLICY "Allow authenticated insert" ON languages
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow authenticated update" ON languages
  FOR UPDATE USING (true);

CREATE POLICY "Allow authenticated delete" ON languages
  FOR DELETE USING (true);
```

### 2. Additional Sounds Table
```sql
CREATE TABLE additional_sounds (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  language_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  file_url TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE additional_sounds ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read access" ON additional_sounds
  FOR SELECT USING (true);

-- Allow authenticated insert/update/delete
CREATE POLICY "Allow authenticated insert" ON additional_sounds
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow authenticated update" ON additional_sounds
  FOR UPDATE USING (true);

CREATE POLICY "Allow authenticated delete" ON additional_sounds
  FOR DELETE USING (true);
```

### 3. Books Table
```sql
CREATE TABLE books (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  language_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  file_url TEXT,
  cover_image_url TEXT,
  shareable_link TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE books ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read access" ON books
  FOR SELECT USING (true);

-- Allow authenticated insert/update/delete
CREATE POLICY "Allow authenticated insert" ON books
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow authenticated update" ON books
  FOR UPDATE USING (true);

CREATE POLICY "Allow authenticated delete" ON books
  FOR DELETE USING (true);
```

### 4. Videos Table
```sql
CREATE TABLE videos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  language_id UUID NOT NULL REFERENCES languages(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  video_url TEXT NOT NULL,
  thumbnail_url TEXT,
  shareable_link TEXT,
  duration_seconds INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read access" ON videos
  FOR SELECT USING (true);

-- Allow authenticated insert/update/delete
CREATE POLICY "Allow authenticated insert" ON videos
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow authenticated update" ON videos
  FOR UPDATE USING (true);

CREATE POLICY "Allow authenticated delete" ON videos
  FOR DELETE USING (true);
```

## Storage Buckets

### Create Storage Buckets

1. **flags** bucket:
   - Go to Storage in Supabase dashboard
   - Create new bucket: `flags`
   - Make it public
   - Allowed MIME types: `image/*`

2. **audios** bucket:
   - Create new bucket: `audios`
   - Make it public
   - Allowed MIME types: `audio/*`

3. **books** bucket:
   - Create new bucket: `books`
   - Make it public
   - Allowed MIME types: `application/pdf, application/epub+zip`

4. **videos** bucket:
   - Create new bucket: `videos`
   - Make it public
   - Allowed MIME types: `video/*`

5. **book_covers** bucket:
   - Create new bucket: `book_covers`
   - Make it public
   - Allowed MIME types: `image/*`

6. **video_thumbnails** bucket:
   - Create new bucket: `video_thumbnails`
   - Make it public
   - Allowed MIME types: `image/*`

## Storage Policies

For each bucket, create the following policies:

```sql
-- Allow public read access
CREATE POLICY "Allow public read access"
ON storage.objects FOR SELECT
USING (bucket_id = 'bucket_name');

-- Allow authenticated upload
CREATE POLICY "Allow authenticated upload"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'bucket_name');

-- Allow authenticated update
CREATE POLICY "Allow authenticated update"
ON storage.objects FOR UPDATE
USING (bucket_id = 'bucket_name');

-- Allow authenticated delete
CREATE POLICY "Allow authenticated delete"
ON storage.objects FOR DELETE
USING (bucket_id = 'bucket_name');
```

Replace `bucket_name` with: `flags`, `audios`, `books`, `videos`, `book_covers`, `video_thumbnails`

## Indexes (Optional but Recommended for Performance)

```sql
-- Index for language queries
CREATE INDEX idx_languages_name ON languages(name);
CREATE INDEX idx_languages_native_name ON languages(native_name);

-- Index for foreign keys
CREATE INDEX idx_additional_sounds_language_id ON additional_sounds(language_id);
CREATE INDEX idx_books_language_id ON books(language_id);
CREATE INDEX idx_videos_language_id ON videos(language_id);
```

## Example Data

### Sample Language Entry
```sql
INSERT INTO languages (name, native_name, flag_url, audio_url, motivational_text, person_num, qr_description)
VALUES (
  'English',
  'English',
  'https://your-project.supabase.co/storage/v1/object/public/flags/english_flag.png',
  'https://your-project.supabase.co/storage/v1/object/public/audios/english_audio.mp3',
  '+1234567890 Learn more about Islam',
  1234567890,
  'https://example.com/english-resources'
);
```

### Sample Book Entry
```sql
INSERT INTO books (language_id, title, description, file_url, cover_image_url, shareable_link)
VALUES (
  'your-language-id-uuid',
  'Introduction to Islam',
  'A comprehensive guide to understanding Islamic teachings',
  'https://your-project.supabase.co/storage/v1/object/public/books/intro_islam.pdf',
  'https://your-project.supabase.co/storage/v1/object/public/book_covers/intro_islam_cover.jpg',
  'https://example.com/books/intro-islam'
);
```

### Sample Video Entry
```sql
INSERT INTO videos (language_id, title, description, video_url, thumbnail_url, shareable_link, duration_seconds)
VALUES (
  'your-language-id-uuid',
  'The Five Pillars of Islam',
  'Learn about the fundamental practices of Islam',
  'https://your-project.supabase.co/storage/v1/object/public/videos/five_pillars.mp4',
  'https://your-project.supabase.co/storage/v1/object/public/video_thumbnails/five_pillars_thumb.jpg',
  'https://example.com/videos/five-pillars',
  600
);
```

## Testing the Setup

After running the SQL scripts:

1. Check that all tables exist in your Supabase project
2. Verify that RLS is enabled for all tables
3. Test that storage buckets are created and accessible
4. Insert sample data to verify relationships work correctly
5. Test the app to ensure data fetches properly

## Notes

- The app caches data locally using SharedPreferences for offline support
- All fields with URLs should contain full public URLs from Supabase Storage
- The `motivational_text` field can contain a phone number at the start (format: `+1234567890 Message text`)
- The `person_num` field is an alternative way to store a WhatsApp contact number
- QR codes can be generated from any `shareable_link` fields
