import 'package:flutter/material.dart';

enum MessageStatus { sending, sent, delivered, read }

class Member {
  const Member({required this.id, required this.name, required this.color});

  final String id;
  final String name;
  final Color color;

  String get initial => name.isEmpty ? '؟' : name.substring(0, 1);
}

class Message {
  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.time,
    this.status = MessageStatus.read,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime time;
  MessageStatus status;
}

class Chat {
  Chat({
    required this.id,
    required this.title,
    required this.members,
    required this.messages,
    this.isGroup = false,
    this.unread = 0,
  });

  final String id;
  final String title;
  final List<Member> members;
  final List<Message> messages;
  final bool isGroup;
  int unread;

  Message? get last => messages.isEmpty ? null : messages.last;

  Color get color => members.isEmpty ? Colors.brown : members.first.color;
}
