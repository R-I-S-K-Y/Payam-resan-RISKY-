import 'package:flutter/material.dart';

import '../models/models.dart';

const Member meMember =
    Member(id: 'me', name: 'من', color: Color(0xFFB5541C));

const _mom = Member(id: 'mom', name: 'مامان', color: Color(0xFFC2185B));
const _dad = Member(id: 'dad', name: 'بابا', color: Color(0xFF2E7D6B));
const _sis = Member(id: 'sis', name: 'خواهر', color: Color(0xFF7B5EA7));
const _bro = Member(id: 'bro', name: 'برادر', color: Color(0xFF3F7CAC));
const _gran = Member(id: 'gran', name: 'مادربزرگ', color: Color(0xFF9A6B00));

DateTime _t(int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}

/// داده‌ی نمایشی. بعد از وصل شدن بک‌اند حذف می‌شود.
List<Chat> buildDemoChats() {
  return [
    Chat(
      id: 'family',
      title: 'خانواده',
      isGroup: true,
      unread: 2,
      members: const [_mom, _dad, _sis, _bro, meMember],
      messages: [
        Message(
            id: 'f1',
            senderId: 'mom',
            text: 'سلام بچه‌ها، جمعه ناهار خونه‌ی ما هستید؟',
            time: _t(9, 12)),
        Message(
            id: 'f2',
            senderId: 'me',
            text: 'آره حتماً، من میام 🌿',
            time: _t(9, 20)),
        Message(
            id: 'f3',
            senderId: 'dad',
            text: 'من هم یه چیزی برای دسر می‌گیرم.',
            time: _t(9, 41)),
        Message(
            id: 'f4',
            senderId: 'sis',
            text: 'منم هستم! ساعت چند خوبه؟',
            time: _t(10, 2)),
        Message(
            id: 'f5',
            senderId: 'mom',
            text: 'ساعت ۱۳ عالیه.',
            time: _t(10, 5)),
      ],
    ),
    Chat(
      id: 'mom',
      title: 'مامان',
      members: const [_mom],
      messages: [
        Message(
            id: 'm1',
            senderId: 'mom',
            text: 'یادت نره امشب زنگ بزنی به مادربزرگ.',
            time: _t(8, 30)),
        Message(
            id: 'm2',
            senderId: 'me',
            text: 'چشم، یادم می‌مونه.',
            time: _t(8, 33)),
      ],
    ),
    Chat(
      id: 'dad',
      title: 'بابا',
      members: const [_dad],
      messages: [
        Message(
            id: 'd1',
            senderId: 'me',
            text: 'بابا ماشین رو بردی تعمیرگاه؟',
            time: _t(7, 55)),
        Message(
            id: 'd2',
            senderId: 'dad',
            text: 'آره، عصر آماده می‌شه.',
            time: _t(8, 10)),
      ],
    ),
    Chat(
      id: 'gran',
      title: 'مادربزرگ',
      unread: 1,
      members: const [_gran],
      messages: [
        Message(
            id: 'g1',
            senderId: 'gran',
            text: 'قربونت برم، شب بخیر.',
            time: _t(21, 15)),
      ],
    ),
    Chat(
      id: 'bro',
      title: 'برادر',
      members: const [_bro],
      messages: [
        Message(
            id: 'b1',
            senderId: 'bro',
            text: 'بازی امشب رو می‌بینی؟',
            time: _t(6, 40)),
      ],
    ),
  ];
}
