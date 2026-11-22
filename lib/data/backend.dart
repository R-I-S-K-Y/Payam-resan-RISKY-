import '../models/models.dart';

/// خطایی که پیامش برای کاربر قابل نمایش است.
class BackendException implements Exception {
  const BackendException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// تنها نقطه‌ی ارتباط اپ با سرور.
///
/// برای عوض کردن سرور (Firebase، Supabase، سرور شخصی و ...) فقط یک
/// پیاده‌سازی تازه از این کلاس نوشته می‌شود و در `main.dart` جایگزین می‌شود.
abstract class Backend {
  /// نسخه‌ی نمایشی بدون سرور؟
  bool get isDemo;

  /// کاربر واردشده؛ `null` یعنی وارد نشده.
  Stream<Member?> authChanges();

  Future<void> signIn(String email, String password);

  Future<void> signOut();

  Stream<List<Member>> watchMembers();

  Stream<List<ChatInfo>> watchChats(String myId);

  Stream<List<Message>> watchMessages(String chatId, String myId);

  Future<void> sendMessage(String chatId, String myId, String text);

  Future<void> markRead(String chatId, String myId, List<String> messageIds);

  /// شناسه‌ی گفتگوی ساخته‌شده (یا موجود) را برمی‌گرداند.
  Future<String> createChat({
    required String myId,
    required String title,
    required List<String> memberIds,
    required bool isGroup,
  });
}
