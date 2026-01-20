# Google Maps Setup Instructions

## To enable the map feature, you need to add a Google Maps API key:

### Step 1: Get a Google Maps API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps JavaScript API (for web)
   - Maps SDK for Android (for Android)
   - Maps SDK for iOS (for iOS)
4. Create credentials → API Key
5. Copy your API key

### Step 2: Add API Key to Your Project

#### For Web (Current Platform):
- Open `web/index.html`
- Replace `YOUR_API_KEY_HERE` with your actual API key in this line:
  ```html
  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY_HERE"></script>
  ```

#### For Android (Optional):
- Open `android/app/src/main/AndroidManifest.xml`
- Add inside the `<application>` tag:
  ```xml
  <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_API_KEY_HERE"/>
  ```

#### For iOS (Optional):
- Open `ios/Runner/AppDelegate.swift`
- Add at the top:
  ```swift
  import GoogleMaps
  ```
- Add in the `application` method:
  ```swift
  GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
  ```

### Step 3: Test the Map Feature
1. Run the app
2. Click the "Map View" floating button or the map icon in the toolbar
3. You should see hotels displayed as markers on the map
4. Click on any marker to see hotel details at the bottom
5. Click the hotel card to view full details

## Features:
✅ View all hotels on an interactive map
✅ Click markers to preview hotel details
✅ Navigate to full hotel details from map
✅ See hotel count badge
✅ Recenter map to view all hotels
✅ Clean and modern UI

## Note:
The map currently shows hotels in Sri Lanka (Colombo area) based on the coordinates in hotels.json.
You can add more hotels with proper latitude/longitude coordinates to see them on the map.
