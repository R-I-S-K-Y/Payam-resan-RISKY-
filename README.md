# 🏡 پیام‌رسان خانواده

[![Android CI](https://github.com/R-I-S-K-Y/Payam-resan-RISKY-/actions/workflows/android.yml/badge.svg)](https://github.com/R-I-S-K-Y/Payam-resan-RISKY-/actions/workflows/android.yml)
![Flutter](https://img.shields.io/badge/Flutter-Android-02569B?logo=flutter&logoColor=white)
![Material 3](https://img.shields.io/badge/Material-3-D97B2D)
![RTL](https://img.shields.io/badge/RTL-فارسی-2E7D6B)

یک پیام‌رسان خصوصی و ساده، فقط برای اعضای خانواده. با **Flutter** نوشته شده، رابط کاملاً فارسی و راست‌به‌چپ دارد و کل ساخت آن (کد، CI، APK و Release) روی GitHub انجام می‌شود، بدون هزینه‌ی سرور.

> **وضعیت:** نسخه‌ی نمایشی (v0.x). اپ فعلاً با داده‌ی نمایشی کار می‌کند و به هیچ سروری وصل نیست. بک‌اند رایگان در مرحله‌ی بعد اضافه می‌شود.

---

## ✨ ویژگی‌ها

| | |
|---|---|
| 🎨 **ظاهر** | Material 3 با رنگ‌های گرم، حالت **روشن، تیره و خودکار** |
| 🔤 **فارسی کامل** | راست‌به‌چپ (RTL)، فونت **وزیرمتن** داخل خود اپ، ارقام فارسی |
| 💬 **چت** | حباب پیام با گوشه‌ی مخصوص هر طرف، ساعت و **تیک وضعیت** (در حال ارسال، ارسال‌شده، تحویل، خوانده‌شده) |
| 👥 **گروه و تک‌نفره** | گفتگوی خانوادگی با نام هر فرستنده و رنگ مخصوص هر عضو |
| 🙂 **آواتار** | آواتار رنگی برای هر عضو، با انیمیشن Hero هنگام ورود به چت |
| 🌊 **انیمیشن** | ورود نرم پیام‌ها، تغییر آیکن تیک، انتقال بین صفحه‌ها |
| 🔒 **حریم خصوصی** | طراحی برای «فقط اعضای خانواده» و بدون هیچ کلید یا رمزی در کد |

---

## 📲 نصب روی اندروید

1. به بخش [**Releases**](https://github.com/R-I-S-K-Y/Payam-resan-RISKY-/releases) برو و آخرین فایل `.apk` را دانلود کن.
2. فایل را روی گوشی باز کن. اگر اندروید پرسید، اجازه‌ی نصب از همین منبع را بده.
3. (اختیاری) مقدار SHA-256 داخل فایل `.sha256` را با فایل دانلودشده مقایسه کن تا از سالم بودنش مطمئن شوی.

> ℹ️ APK فعلی با کلید آزمایشی (debug) امضا شده و فقط برای نصب دستی روی گوشی‌های خانواده مناسب است.

---

## 🛠 ساخت از سورس

نیاز به [Flutter](https://docs.flutter.dev/get-started/install) (کانال stable) دارید.

```bash
# یک بار: ساخت پوشه‌ی اندروید (در ریپو نگهداری نمی‌شود)
flutter create --platforms=android --org com.family --project-name family_messenger /tmp/scaffold
cp -r /tmp/scaffold/android ./android

flutter pub get
flutter analyze
flutter test
flutter run                   # اجرا روی دستگاه یا شبیه‌ساز
flutter build apk --release   # خروجی: build/app/outputs/flutter-apk/app-release.apk
```

ساخت خودکار هم روی GitHub Actions انجام می‌شود:

- **Android CI** (`.github/workflows/android.yml`): در هر push و pull request، کد را تحلیل می‌کند، تست‌ها را اجرا می‌کند و APK را به‌عنوان Artifact می‌سازد.
- **Release** (`.github/workflows/release.yml`): با زدن یک تگ مثل `v0.1.0` یا پوش یک شاخه مثل `release/v0.1.0`، APK و فایل SHA-256 را می‌سازد و در Releases منتشر می‌کند.

---

## 🗂 ساختار پروژه

```
lib/
├── main.dart               نقطه‌ی شروع
├── app.dart                MaterialApp، RTL، تم
├── theme/app_theme.dart    رنگ‌های گرم Material 3 و فونت
├── models/models.dart      Member، Message، Chat
├── data/demo_data.dart     داده‌ی نمایشی (بعداً حذف می‌شود)
├── state/app_state.dart    وضعیت برنامه (تم، ورود، گفتگوها)
├── screens/                ورود، گفتگوها، چت، تنظیمات
├── widgets/                آواتار، حباب پیام
└── utils/fa.dart           ارقام و ساعت فارسی
assets/fonts/               فونت وزیرمتن
test/                       تست‌های ویجت
```

---

## 🔐 امنیت و حریم خصوصی

- هیچ رمز، توکن یا کلیدی در کد، لاگ یا ریپو قرار نمی‌گیرد. `.gitignore` فایل‌های حساس (keystore، `google-services.json`، `.env` و مانند آن) را رد می‌کند.
- امضای نسخه‌ی نهایی با keystore شخصی و از طریق **GitHub Secrets** انجام خواهد شد، نه داخل ریپو.
- ورود فقط برای اعضای خانواده خواهد بود و در مرحله‌ی بک‌اند با قوانین امنیتی درست اعمال می‌شود.
- اگر مشکل امنیتی دیدید، لطفاً آن را عمومی نکنید و مستقیم به صاحب پروژه بگویید.

---

## 🗺 نقشه‌ی راه

- [x] اپ با رابط کامل و داده‌ی نمایشی
- [x] CI و ساخت خودکار APK
- [x] انتشار در Releases
- [ ] بک‌اند رایگان (Firebase یا Supabase) و ورود اعضای خانواده
- [ ] ذخیره و همگام‌سازی پیام‌ها، قوانین امنیتی
- [ ] نوتیفیکیشن (باید بررسی شود که در ایران بدون VPN کار می‌کند یا نه)
- [ ] امضای واقعی APK با keystore
- [ ] نسخه‌ی iOS (در صورت نیاز خانواده)

---

## 🙏 قدردانی

- فونت [وزیرمتن](https://github.com/rastikerdar/vazirmatn) اثر صابر راستی‌کردار، با مجوز SIL OFL 1.1 (متن مجوز: `assets/fonts/OFL.txt`).
- ساخته‌شده با [Flutter](https://flutter.dev).

---

برای یادداشت‌های فنی و تصمیم‌های پروژه، فایل [`NOTES.md`](NOTES.md) را ببینید.
