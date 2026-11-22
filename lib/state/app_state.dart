import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  AppState() : chats = buildDemoChats();

  final Member me = meMember;
  final List<Chat> chats;

  ThemeMode _themeMode = ThemeMode.system;
  bool _loggedIn = false;

  ThemeMode get themeMode => _themeMode;
  bool get loggedIn => _loggedIn;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// ورود نمایشی. ورود واقعی بعد از وصل شدن بک‌اند اضافه می‌شود.
  void login() {
    _loggedIn = true;
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    notifyListeners();
  }

  void openChat(Chat chat) {
    if (chat.unread != 0) {
      chat.unread = 0;
      notifyListeners();
    }
  }

  void sendMessage(Chat chat, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final message = Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      senderId: me.id,
      text: trimmed,
      time: DateTime.now(),
      status: MessageStatus.sending,
    );
    chat.messages.add(message);
    notifyListeners();

    // شبیه‌سازی وضعیت ارسال تا زمان وصل شدن سرور.
    _advance(message, MessageStatus.sent, 500);
    _advance(message, MessageStatus.delivered, 1300);
    _advance(message, MessageStatus.read, 2600);
  }

  void _advance(Message message, MessageStatus status, int millis) {
    Future<void>.delayed(Duration(milliseconds: millis), () {
      message.status = status;
      notifyListeners();
    });
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in context');
    return scope!.notifier!;
  }
}
