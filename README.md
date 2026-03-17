# 🌊 FloodWatch Chonburi

## ⚡ เริ่มรันทันที

### Backend
```bash
cd backend
npm install
# แก้ FIREBASE_CLIENT_EMAIL ใน .env ก่อน (ดูด้านล่าง)
npm run dev
```

### Flutter
```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```

---

## 🔑 สิ่งที่ต้องทำก่อนรัน — แก้ FIREBASE_CLIENT_EMAIL

1. เปิดไฟล์ JSON ที่ download จาก Firebase Console
2. หาบรรทัด `"client_email"`:
   ```json
   "client_email": "firebase-adminsdk-ab12c@floodchonburi.iam.gserviceaccount.com"
   ```
3. Copy ค่านั้น → เปิด `backend/.env` → แทน `FIREBASE_CLIENT_EMAIL=`

---

## ✅ สถานะ Keys

| Key | สถานะ |
|-----|-------|
| MongoDB URI | ✅ ใส่แล้ว |
| Firebase Project ID | ✅ ใส่แล้ว |
| Firebase Private Key | ✅ ใส่แล้ว |
| **Firebase Client Email** | ⚠️ **ต้องใส่เพิ่ม** |
| VAPID Public Key | ✅ ใส่แล้ว |
| VAPID Private Key | ✅ ใส่แล้ว |

---

## 📡 ทดสอบ API

```
http://localhost:4000/health      → เช็ค server
http://localhost:4000/api/flood   → ข้อมูลน้ำทุกอำเภอ
```

---

## 📁 โครงสร้าง

```
floodwatch-final/
├── backend/
│   ├── .env                    ← ตั้งค่า (แก้ client_email!)
│   ├── package.json
│   └── src/
│       ├── index.js
│       ├── middleware/auth.js
│       ├── models/
│       │   ├── User.js
│       │   └── FloodData.js
│       ├── routes/
│       │   ├── auth.js
│       │   ├── flood.js
│       │   ├── user.js
│       │   └── alert.js
│       └── services/
│           ├── floodFetcher.js        ← Open-Meteo + ThaiWater
│           └── notificationService.js ← Push Notifications
│
└── flutter_app/
    ├── pubspec.yaml
    └── lib/
        ├── main.dart
        ├── theme/app_theme.dart
        ├── models/district.dart
        ├── services/
        │   ├── api_service.dart    ← เชื่อม Backend
        │   └── auth_service.dart   ← Login
        ├── screens/
        │   ├── login_screen.dart
        │   ├── home_screen.dart
        │   ├── map_screen.dart     ← แผนที่ OpenStreetMap
        │   └── profile_screen.dart
        └── widgets/
            ├── district_card.dart
            ├── district_detail_sheet.dart
            └── status_summary.dart
```
