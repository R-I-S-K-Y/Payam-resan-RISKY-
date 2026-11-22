import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'data/backend.dart';
import 'data/demo_backend.dart';
import 'data/firebase_backend.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // اگر تنظیمات Firebase داخل برنامه نباشد (google-services.json)،
  // اپ به‌صورت نمایشی و بدون سرور اجرا می‌شود.
  Backend backend;
  try {
    await Firebase.initializeApp();
    backend = FirebaseBackend();
  } catch (_) {
    backend = DemoBackend();
  }

  runApp(FamilyApp(backend: backend));
}
