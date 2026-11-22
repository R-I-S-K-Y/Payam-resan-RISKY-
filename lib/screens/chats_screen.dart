import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../utils/fa.dart';
import '../widgets/avatar.dart';
import 'chat_screen.dart';
import 'new_chat_sheet.dart';
import 'settings_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final chats = app.chats
      ..sort((a, b) {
        final at = a.previewTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bt = b.previewTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bt.compareTo(at);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('گفتگوها'),
        actions: [
          IconButton(
            tooltip: 'تنظیمات',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showNewChatSheet(context),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('گفتگوی جدید'),
      ),
      body: chats.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'هنوز گفتگویی نیست.\nبا دکمه‌ی «گفتگوی جدید» شروع کنید.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant, height: 1.7),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(top: 4, bottom: 96),
              itemCount: chats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, i) => _ChatTile(chat: chats[i]),
            ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.chat});

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final time = chat.previewTime;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Hero(
        tag: 'avatar-${chat.id}',
        child: Avatar(
          label: chat.title,
          color: chat.color,
          icon: chat.isGroup ? Icons.groups_rounded : null,
        ),
      ),
      title: Text(
        chat.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
      subtitle: Text(
        chat.preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: scheme.onSurfaceVariant),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (time != null)
            Text(
              timeLabel(time),
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          const SizedBox(height: 8),
          if (chat.hasUnread)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(height: 12),
        ],
      ),
      onTap: () {
        AppScope.of(context).openChat(chat);
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ChatScreen(chat: chat)),
        );
      },
    );
  }
}
