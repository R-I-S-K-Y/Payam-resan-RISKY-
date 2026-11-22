import 'dart:async';

import 'package:flutter/material.dart';

import '../data/backend.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  AppState(this.backend) {
    _authSub = backend.authChanges().listen(
      _onAuth,
      onError: (Object _) {
        _authReady = true;
        notifyListeners();
      },
    );
  }

  final Backend backend;

  Member? _me;
  bool _authReady = false;
  ThemeMode _themeMode = ThemeMode.system;
  List<Member> _members = const <Member>[];
  List<ChatInfo> _infos = const <ChatInfo>[];
  final Map<String, Chat> _chats = <String, Chat>{};

  StreamSubscription<Member?>? _authSub;
  StreamSubscription<List<Member>>? _memberSub;
  StreamSubscription<List<ChatInfo>>? _chatSub;
  final Map<String, StreamSubscription<List<Message>>> _msgSubs =
      <String, StreamSubscription<List<Message>>>{};
  final Map<String, Set<String>> _readSent = <String, Set<String>>{};

  ThemeMode get themeMode => _themeMode;
  bool get authReady => _authReady;
  bool get loggedIn => _me != null;
  Member get me => _me!;
  List<Member> get members => _members;
  List<Chat> get chats => _chats.values.toList();

  Chat? chatById(String id) => _chats[id];

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) =>
      backend.signIn(email, password);

  Future<void> signOut() => backend.signOut();

  void _onAuth(Member? member) {
    _authReady = true;
    final changed = member?.id != _me?.id;
    _me = member;
    if (changed) {
      _stopData();
      if (member != null) _startData(member.id);
    }
    notifyListeners();
  }

  void _startData(String myId) {
    _memberSub = backend.watchMembers().listen(
      (list) {
        _members = list;
        _rebuild();
      },
      onError: (Object _) {},
    );
    _chatSub = backend.watchChats(myId).listen(
      (list) {
        _infos = list;
        _rebuild();
      },
      onError: (Object _) {},
    );
  }

  void _stopData() {
    _memberSub?.cancel();
    _chatSub?.cancel();
    _memberSub = null;
    _chatSub = null;
    for (final s in _msgSubs.values) {
      s.cancel();
    }
    _msgSubs.clear();
    _readSent.clear();
    _members = const <Member>[];
    _infos = const <ChatInfo>[];
    _chats.clear();
  }

  void _rebuild() {
    final myId = _me?.id;
    if (myId == null) return;
    final byId = <String, Member>{for (final m in _members) m.id: m};
    final seen = <String>{};

    for (final info in _infos) {
      seen.add(info.id);
      final chat = _chats.putIfAbsent(info.id, () => Chat(id: info.id));
      final members = <Member>[
        for (final id in info.memberIds) byId[id] ?? Member(id: id, name: '؟'),
      ];
      Member? other;
      for (final m in members) {
        if (m.id != myId) {
          other = m;
          break;
        }
      }
      chat.isGroup = info.isGroup;
      chat.members = members;
      chat.title = info.isGroup
          ? (info.title.isEmpty ? 'گروه' : info.title)
          : (other?.name ?? 'گفتگو');
      chat.accentId = info.isGroup ? info.id : (other?.id ?? info.id);
      chat.lastText = info.lastText;
      chat.lastTime = info.lastTime;
      chat.hasUnread = info.hasUnreadFor(myId);
    }

    _chats.removeWhere((id, _) => !seen.contains(id));
    notifyListeners();
  }

  /// شروع دریافت پیام‌های یک گفتگو (هنگام باز شدن صفحه‌ی چت).
  void openChat(Chat chat) {
    if (_me == null) return;
    _msgSubs[chat.id]?.cancel();
    _msgSubs[chat.id] = backend.watchMessages(chat.id, me.id).listen(
      (list) {
        chat.messages = list;
        _markRead(chat);
        notifyListeners();
      },
      onError: (Object _) {},
    );
  }

  void closeChat(Chat chat) {
    _msgSubs.remove(chat.id)?.cancel();
    _readSent.remove(chat.id);
  }

  void _markRead(Chat chat) {
    final myId = _me?.id;
    if (myId == null) return;
    final sent = _readSent.putIfAbsent(chat.id, () => <String>{});
    final ids = <String>[
      for (final m in chat.messages)
        if (m.senderId != myId &&
            !m.readBy.contains(myId) &&
            !sent.contains(m.id))
          m.id,
    ];
    final needChat = chat.hasUnread && !sent.contains('_chat');
    if (ids.isEmpty && !needChat) return;
    sent
      ..addAll(ids)
      ..add('_chat');
    backend.markRead(chat.id, myId, ids).catchError((Object _) {
      sent.removeAll(ids);
    });
  }

  Future<void> sendMessage(Chat chat, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return Future<void>.value();
    return backend.sendMessage(chat.id, me.id, trimmed);
  }

  Future<Chat?> createChat({
    required String title,
    required List<String> memberIds,
    required bool isGroup,
  }) async {
    final id = await backend.createChat(
      myId: me.id,
      title: title,
      memberIds: memberIds,
      isGroup: isGroup,
    );
    for (var i = 0; i < 30; i++) {
      final chat = _chats[id];
      if (chat != null) return chat;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return null;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _stopData();
    super.dispose();
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
