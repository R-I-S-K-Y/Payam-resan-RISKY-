#!/usr/bin/env bash
# ساخت پوشه‌ی android (که داخل ریپو نیست) و وصل کردن Firebase.
# فایل google-services.json هرگز داخل ریپو نمی‌رود؛ از Secret گیت‌هاب
# با نام GOOGLE_SERVICES_JSON (متغیر محیطی) خوانده می‌شود.
set -euo pipefail

PACKAGE_ORG="com.risky"
PROJECT_NAME="familymessenger" # applicationId نهایی: com.risky.familymessenger

if [ ! -d android ]; then
  scaffold="$(mktemp -d)/${PROJECT_NAME}"
  flutter create --platforms=android --org "${PACKAGE_ORG}" \
    --project-name "${PROJECT_NAME}" "${scaffold}"
  cp -r "${scaffold}/android" ./android
fi

manifest="android/app/src/main/AndroidManifest.xml"
sed -i 's/android:label="[^"]*"/android:label="پیام‌رسان خانواده"/' "${manifest}"

app_gradle="android/app/build.gradle.kts"
settings_gradle="android/settings.gradle.kts"

# راه‌حل موقت: lint اندروید داخل بعضی پلاگین‌های Flutter خطای داخلی می‌دهد
# (NoSuchMethodError در JavaDocParser) و بیلد Release را می‌شکند.
build_gradle="android/build.gradle.kts"
if ! grep -q 'lintVital' "${build_gradle}"; then
  cat >> "${build_gradle}" <<'GRADLE'

subprojects {
    tasks.configureEach {
        if (name.startsWith("lintVital")) {
            enabled = false
        }
    }
}
GRADLE
fi

# Firebase حداقل به minSdk 23 نیاز دارد.
sed -i 's/minSdk = flutter.minSdkVersion/minSdk = maxOf(23, flutter.minSdkVersion)/' "${app_gradle}"

if [ -n "${GOOGLE_SERVICES_JSON:-}" ]; then
  printf '%s' "${GOOGLE_SERVICES_JSON}" > android/app/google-services.json

  if ! grep -q 'com.google.gms.google-services' "${settings_gradle}"; then
    sed -i '/id("com.android.application") version/a\    id("com.google.gms.google-services") version "4.4.2" apply false' "${settings_gradle}"
  fi
  if ! grep -q 'com.google.gms.google-services' "${app_gradle}"; then
    sed -i '0,/id("com.android.application")/s//id("com.android.application")\n    id("com.google.gms.google-services")/' "${app_gradle}"
  fi

  grep -q 'com.google.gms.google-services' "${settings_gradle}" \
    || { echo "ERROR: could not add google-services plugin to ${settings_gradle}"; exit 1; }
  grep -q 'com.google.gms.google-services' "${app_gradle}" \
    || { echo "ERROR: could not add google-services plugin to ${app_gradle}"; exit 1; }
  echo "Firebase config written and google-services plugin enabled."
else
  echo "GOOGLE_SERVICES_JSON not set: building without Firebase (demo mode)."
fi
