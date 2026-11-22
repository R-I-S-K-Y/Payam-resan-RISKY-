import 'dart:async';

import '../models/models.dart';
import 'backend.dart';

const Member _me = Member(id: 'me', name: 'من');
const Member _mom = Member(id: 'mom', name: 'مامان');
const Member _dad = Member(id: 'dad', name: 'بابا');
const Member _sis = Member(id: 'sis', name: 'خواهر');
const Member _bro = Member(id: 'bro', name: 'برادر');
const Member _gran = Member(id: 'gran', name: 'مادربزرگ');

DateTime _t(int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}

Message _m(String id, String sender, String text, int h, int mi) {
  return Message(
    id: id,
    senderId: sender,
    text: text,
    time: _t(h, mi),
    status: MessageStatus.read,
    readBy: [sender],
  );
}

Map<String, List<Message>> _seedMessages() {
  return {
    'family': [
      _m('f1', 'mom', 'سلام بچه‌ها، جمعه ناهار خونه‌ی ما هستید؟', 9, 12),
      _m('f2', 'me', 'آره حتماً، من میام 🌿', 9, 20),
      _m('f3', 'dad', 'من هم یه چیزی برای دسر می‌گیرم.', 9, 41),
      _m('f4', 'sis', 'منم هستم! ساعت چند خوبه؟', 10, 2),
      _m('f5', 'mom', 'ساعت ۱۳ عالیه.', 10, 5),
    ],
    'mom': [
      _m('m1', 'mom', 'یادت نره امشب زنگ بزنی به مادربزرگ.', 8, 30),
      _m('m2', 'me', 'چشم، یادم می‌مونه.', 8, 33),
    ],
    'dad': [
      _m('d1', 'me', 'بابا ماشین رو بردی تعمیرگاه؟', 7, 55),
      _m('d2', 'dad', 'آره، عصر آماده می‌شه.', 8, 10),
    ],
    'gran': [
      _m('g1', 'gran', 'قربونت برم، شب بخیر.', 21, 15),
    ],
    'bro': [
      _m('b1', 'bro', 'بازی امشب رو می‌بینی؟', 6, 40),
    ],
  };
}

List<ChatInfo> _seedChats(Map<String, List<Message>> messages) {
  ChatInfo info(
    String id,
    String title,
    bool group,
    List<String> members, {
    bool unread = false,
  }) {
    final last = messages[id]!.last;
    return ChatInfo(
      id: id,
      title: title,
      isGroup: group,
      memberIds: members,
      lastText: last.text,
      lastTime: last.time,
      lastSenderId: last.senderId,
      lastReadBy: unread ? [last.senderId] : [last.senderId, 'me'],
    );
  }

  return [
    info('family', 'خانواده', true, ['mom', 'dad', 'sis', 'bro', 'me'],
        unread: true),
    info('mom', '', false, ['me', 'mom']),
    info('dad', '', false, ['me', 'dad']),
    info('gran', '', false, ['me', 'gran'], unread: true),
    info('bro', '', false, ['me', 'bro']),
  ];
}

/// نسخه‌ی نمایشی بدون سرور. داده فقط در حافظه است.
class DemoBackend implements Backend {
  factory DemoBackend() => DemoBackend._(_seedMessages());

  DemoBackend._(this._messages) : _chats = _seedChats(_messages);

  final Map<String, List<Message>> _messages;
  final List<ChatInfo> _chats;
  final StreamController<Member?> _authCtrl =
      StreamController<Member?>.broadcast();
  final StreamController<void> _chatCtrl = StreamController<void>.broadcast();
  final StreamController<String> _msgCtrl = StreamController<String>.broadcast();
  Member? _current;

  @override
  bool get isDemo => true;

  @override
  Stream<Member?> authChanges() async* {
    yield _current;
    yield* _authCtrl.stream;
  }

  @override
  Future<void> signIn(String email, String password) async {
    _current = _me;
    _authCtrl.add(_me);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _authCtrl.add(null);
  }

  @override
  Stream<List<Member>> watchMembers() =>
      Stream<List<Member>>.value(const [_me, _mom, _dad, _sis, _bro, _gran]);

  @override
  Stream<List<ChatInfo>> watchChats(String myId) async* {
    yield List<ChatInfo>.of(_chats);
    yield* _chatCtrl.stream.map((_) => List<ChatInfo>.of(_chats));
  }

  @override
  Stream<List<Message>> watchMessages(String chatId, String myId) async* {
    yield List<Message>.of(_messages[chatId] ?? const <Message>[]);
    yield* _msgCtrl.stream
        .where((id) => id == chatId)
        .map((_) => List<Message>.of(_messages[chatId] ?? const <Message>[]));
  }

  @override
  Future<void> sendMessage(String chatId, String myId, String text) async {
    final list = _messages.putIfAbsent(chatId, () => <Message>[]);
    final message = Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      senderId: myId,
      text: text,
      time: DateTime.now(),
      status: MessageStatus.sending,
      readBy: [myId],
    );
    list.add(message);
    _touchChat(chatId, message);
    _msgCtrl.add(chatId);

    // شبیه‌سازی وضعیت ارسال.
    Timer(const Duration(milliseconds: 500),
        () => _advance(chatId, message, MessageStatus.sent));
    Timer(const Duration(milliseconds: 1300),
        () => _advance(chatId, message, MessageStatus.delivered));
    Timer(const Duration(milliseconds: 2600),
        () => _advance(chatId, message, MessageStatus.read));
  }

  void _advance(String chatId, Message message, MessageStatus status) {
    message.status = status;
    _msgCtrl.add(chatId);
  }

  void _touchChat(String chatId, Message m) {
    final i = _chats.indexWhere((c) => c.id == chatId);
    if (i < 0) return;
    _chats[i] = _chats[i].withLast(
      text: m.text,
      time: m.time,
      sender: m.senderId,
      readBy: [m.senderId],
    );
    _chatCtrl.add(null);
  }

  @override
  Future<void> markRead(
    String chatId,
    String myId,
    List<String> messageIds,
  ) async {
    final i = _chats.indexWhere((c) => c.id == chatId);
    if (i < 0) return;
    final c = _chats[i];
    if (c.lastReadBy.contains(myId)) return;
    _chats[i] = c.withLast(
      text: c.lastText,
      time: c.lastTime ?? DateTime.now(),
      sender: c.lastSenderId,
      readBy: [...c.lastReadBy, myId],
    );
    _chatCtrl.add(null);
  }

  @override
  Future<String> createChat({
    required String myId,
    required String title,
    required List<String> memberIds,
    required bool isGroup,
  }) async {
    final ids = <String>{...memberIds, myId}.toList()..sort();
    final id = isGroup
        ? 'g${DateTime.now().microsecondsSinceEpoch}'
        : ids.join('_');
    if (_chats.any((c) => c.id == id)) return id;
    _chats.add(ChatInfo(
      id: id,
      title: title,
      isGroup: isGroup,
      memberIds: ids,
    ));
    _messages[id] = <Message>[];
    _chatCtrl.add(null);
    return id;
  }
}
