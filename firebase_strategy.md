# Mini Deha - Firebase & Backend Strategy

This document outlines the technical strategy for connecting the "Mini Deha" Flutter app with Firebase services.

## 1. Firebase Configuration

### Prerequisites
- Create a new project in [Firebase Console](https://console.firebase.google.com/).
- Enable **Firestore Database**.
- Enable **Authentication** (Anonymous & Email).
- Add Android/iOS apps in Project Settings and download `google-services.json` / `GoogleService-Info.plist`.

### Dependencies
Added to `pubspec.yaml`:
- `firebase_core`: Initialization.
- `cloud_firestore`: Database interactions.
- `firebase_auth`: User management (Anonymous for kids, Link for parents).

## 2. Database Schema (Firestore)

We will use a NoSQL structure optimized for read operations.

### Collection: `categories`
Stores the main video categories.
```json
{
  "id": "painters",
  "title": "Küçük Ressamlar",
  "icon_code": "paintbrush",
  "color_hex": "#FF4081",
  "description": "Resim ve çizim videoları",
  "order": 1
}
```

### Collection: `videos`
Stores video metadata. This can be a top-level collection or a sub-collection of categories. **Recommendation**: Top-level collection for easier querying (e.g., "Newest videos").

```json
{
  "id": "video_123",
  "category_id": "painters",
  "title": "Kedi Nasıl Çizilir?",
  "youtube_id": "dQw4w9WgXcQ",
  "duration_seconds": 300,
  "is_premium": false,
  "created_at": "Timestamp"
}
```

### Collection: `users`
Stores user progress and settings.

```json
{
  "uid": "user_xyz",
  "is_premium": false,
  "parent_pin": "1234", (Hashed)
  "settings": {
    "daily_limit_minutes": 30,
    "blue_light_filter": true
  },
  "stats": {
    "total_watch_time": 1200,
    "favorite_category": "painters"
  }
}
```

## 3. Implementation Logic

### Fetching Content
Create a `ContentProvider` class that listens to Firestore streams:
```dart
Stream<List<CategoryModel>> getCategories() {
  return _firestore.collection('categories')
      .orderBy('order')
      .snapshots()
      .map((snapshot) => ...);
}
```

### Smart Timer (Time Limit)
- Use a local `Timer` in a `SessionProvider`.
- When video plays, start timer.
- When timer > `daily_limit`, show "Sleepy Rabbit" overlay and pause video.
- **Security**: Store the "start time" in `SharedPreferences` to prevent app restart exploits.

### Freemium Logic
- Fetch `is_premium` status from `users/{uid}`.
- If `!is_premium` and `video.is_premium == true`, show subscription dialog.
- Use `in_app_purchase` package to handle payments, then update `is_premium` in Firestore via Cloud Function (secure) or directly (less secure but easier for MVP).
