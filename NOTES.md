# یادداشت‌های پروژه: پیام‌رسان خانواده

## هدف
یک پیام‌رسان خصوصی فقط برای اعضای خانواده، با Flutter (فعلاً اندروید). بک‌اند رایگان و بعد از تمام شدن خود اپ اضافه می‌شود.

## وضعیت فعلی
- اپ از طریق یک لایه‌ی واسط (`lib/data/backend.dart`) با سرور حرف می‌زند. اگر تنظیمات Firebase داخل بیلد باشد از Firebase استفاده می‌کند، وگرنه به‌صورت نمایشی (DemoBackend) اجرا می‌شود.
- صفحه‌ها: ورود، لیست گفتگوها، چت (حباب پیام با تیک)، تنظیمات (تم تیره/روشن).
- ساخت APK روی GitHub Actions انجام می‌شود (`.github/workflows/android.yml`).

## ساختار
```
lib/
  main.dart            نقطه‌ی شروع
  app.dart             MaterialApp، RTL، تم
  theme/app_theme.dart رنگ‌های گرم Material 3، فونت وزیرمتن
  models/models.dart   Member، Message، Chat
  data/backend.dart    رابط انتزاعی سرور (برای عوض کردن سرور فقط پیاده‌سازی جدید می‌نویسید)
  data/firebase_backend.dart  پیاده‌سازی Firebase (Auth + Firestore)
  data/demo_backend.dart      نسخه‌ی نمایشی بدون سرور
  state/app_state.dart وضعیت برنامه (تم، ورود، گفتگوها)
  screens/             ورود، گفتگوها، چت، تنظیمات
  widgets/             آواتار، حباب پیام
assets/fonts/          فونت Vazirmatn (مجوز OFL، فایل OFL.txt)
```

## تصمیم‌ها
- پوشه‌ی `android/` در ریپو نیست و CI آن را با `tool/setup_android.sh` می‌سازد (applicationId: `com.risky.familymessenger`). اگر خواستید محلی بسازید، یک بار `flutter create --platforms=android .` بزنید.
- فونت داخل اپ است تا به سرویس گوگل وابسته نباشد.
- APK نسخه‌ی Release فعلاً با کلید debug امضا می‌شود. برای انتشار واقعی باید keystore بسازید و در GitHub Secrets بگذارید (هرگز در ریپو نگذارید).
- بک‌اند بعداً: Firebase (پلن رایگان) یا Supabase. نگرانی: نوتیفیکیشن (FCM) و سرویس‌های گوگل ممکن است در ایران بدون VPN کار نکنند و باید قبل از انتخاب نهایی بررسی شود.

## قواعد کار
- روی شاخه‌ی جدید کار می‌شود، نه `main`.
- force-push و حذف شاخه ممنوع است.
- بدون اجازه‌ی صاحب پروژه merge و Release انجام نمی‌شود.
- بعد از هر push نتیجه‌ی CI خوانده و خطاها درست می‌شود.

## امنیت و حریم خصوصی
- هیچ رمز، کلید یا توکنی در کد، لاگ یا ریپو قرار نمی‌گیرد (`.gitignore` فایل‌های حساس را رد می‌کند).
- ورود فقط برای اعضای خانواده خواهد بود (در مرحله‌ی بک‌اند با قوانین امنیتی درست اعمال می‌شود).
- ریپو بهتر است Private باشد.

## کارهای بعدی
1. نتیجه‌ی CI و رفع خطاها
2. Release (با اجازه‌ی صاحب پروژه)
3. بررسی Firebase/Supabase، ورود اعضا، ذخیره و همگام‌سازی پیام، نوتیفیکیشن

## توجه
راهنمای دوست (بخش ۳.۱ و ۳.۲) هنوز دریافت نشده است. workflow و این فایل فعلاً بر اساس رویه‌ی استاندارد نوشته شده‌اند و بعد از رسیدن راهنما با آن هماهنگ می‌شوند.

## راه‌اندازی Firebase (یک‌بار)
1. در کنسول Firebase اپ اندروید با package name `com.risky.familymessenger` ثبت شود و `google-services.json` همان اپ دانلود شود.
2. محتوای آن فایل در ریپو ← Settings ← Secrets and variables ← Actions ← Secret به نام `GOOGLE_SERVICES_JSON` ذخیره شود. فایل هرگز داخل ریپو commit نمی‌شود.
3. Authentication ← Sign-in method ← Email/Password فعال شود.
4. Firestore Database در حالت Production ساخته شود.
5. محتوای `firestore.rules` در Firestore ← Rules کپی و Publish شود.
6. برای هر عضو خانواده:
   - Authentication ← Users ← Add user (ایمیل با حروف کوچک و رمز).
   - Firestore ← Start collection با نام `allowed_emails` و شناسه‌ی سند برابر همان ایمیل (حروف کوچک). یک فیلد دلخواه مثل `ok: true` بگذارید.
7. پیشنهاد: در Authentication ← Settings ← User actions گزینه‌ی ثبت‌نام (Enable create) را خاموش کنید.
8. کلید API را در Google Cloud Console فقط برای package name و SHA-1 این اپ محدود کنید.

## ساختار داده‌ی Firestore
- `allowed_emails/{email}` فقط از کنسول ساخته می‌شود.
- `users/{uid}`: نام و ایمیل.
- `chats/{id}`: عنوان، گروه یا دونفره، `memberIds` و خلاصه‌ی آخرین پیام.
- `chats/{id}/messages/{id}`: فرستنده، متن، زمان و `readBy`.

## محدودیت‌های فعلی
- نوتیفیکیشن (FCM) هنوز اضافه نشده و باید دسترسی از ایران بدون VPN تست شود.
- ارسال عکس و فایل نیاز به Cloud Storage دارد که روی پلن رایگان نیست.
- نشانگر خوانده‌نشده روی لیست گفتگوها فقط یک نقطه است (تعداد نشان داده نمی‌شود).
