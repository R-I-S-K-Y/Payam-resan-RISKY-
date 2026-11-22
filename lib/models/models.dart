import 'package:flutter/material.dart';

const List<Color> _palette = [
  Color(0xFFB5541C),
  Color(0xFFC2185B),
  Color(0xFF2E7D6B),
  Color(0xFF7B5EA7),
  Color(0xFF3F7CAC),
  Color(0xFF9A6B00),
  Color(0xFF8D4F3A),
  Color(0xFF00796B),
];

/// رنگ ثابت هر عضو بر اساس شناسه‌اش.
Color memberColor(String id) {
  var h = 0;
  for (final c in id.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return _palette[h % _palette.length];
}

enum MessageStatus { sending, sent, delivered, read }

class Member {
  const Member({required this.id, required this.name});

  final String id;
  final String name;

  Color get color => memberColor(id);
}

class Message {
  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.time,
    this.status = MessageStatus.sent,
    this.readBy = const <String>[],
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime time;
  MessageStatus status;
  final List<String> readBy;
}

/// اطلاعات خام یک گفتگو که از سرور می‌آید.
class ChatInfo {
  const ChatInfo({
    required this.id,
    required this.title,
    required this.isGroup,
    required this.memberIds,
    this.lastText = '',
    this.lastTime,
    this.lastSenderId = '',
    this.lastReadBy = const <String>[],
  });

  final String id;
  final String title;
  final bool isGroup;
  final List<String> memberIds;
  final String lastText;
  final DateTime? lastTime;
  final String lastSenderId;
  final List<String> lastReadBy;

  bool hasUnreadFor(String uid) =>
      lastSenderId.isNotEmpty &&
      lastSenderId != uid &&
      !lastReadBy.contains(uid);

  ChatInfo withLast({
    required String text,
    required DateTime time,
    required String sender,
    required List<String> readBy,
  }) {
    return ChatInfo(
      id: id,
      title: title,
      isGroup: isGroup,
      memberIds: memberIds,
      lastText: text,
      lastTime: time,
      lastSenderId: sender,
      lastReadBy: readBy,
    );
  }
}

/// گفتگو به شکلی که صفحه‌ها نمایش می‌دهند.
class Chat {
  Chat({required this.id});

  final String id;
  String title = '';
  bool isGroup = false;
  String accentId = '';
  List<Member> members = const <Member>[];
  List<Message> messages = const <Message>[];
  String lastText = '';
  DateTime? lastTime;
  bool hasUnread = false;

  String get preview => messages.isNotEmpty ? messages.last.text : lastText;

  DateTime? get previewTime =>
      messages.isNotEmpty ? messages.last.time : lastTime;

  Color get color => memberColor(accentId.isEmpty ? id : accentId);
}
