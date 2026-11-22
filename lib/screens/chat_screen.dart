import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/avatar.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chat});

  final Chat chat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  AppState? _app;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _app = AppScope.of(context);
  }

  @override
  void dispose() {
    _app?.closeChat(widget.chat);
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    final app = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    app.sendMessage(widget.chat, text).catchError((Object _) {
      messenger.showSnackBar(
        const SnackBar(content: Text('ارسال پیام انجام نشد')),
      );
    });
    _controller.clear();
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Member? _member(String id) {
    for (final m in widget.chat.members) {
      if (m.id == id) return m;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final chat = widget.chat;
    final scheme = Theme.of(context).colorScheme;
    final messages = chat.messages;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Hero(
              tag: 'avatar-${chat.id}',
              child: Avatar(
                label: chat.title,
                color: chat.color,
                radius: 18,
                icon: chat.isGroup ? Icons.groups_rounded : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  if (chat.isGroup)
                    Text(
                      chat.members.map((m) => m.name).join('، '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'هنوز پیامی نیست. اولین پیام را بفرستید 🌿',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final isMine = message.senderId == app.me.id;
                      final sender = isMine ? null : _member(message.senderId);
                      return MessageBubble(
                        key: ValueKey(message.id),
                        message: message,
                        isMine: isMine,
                        senderName: chat.isGroup ? sender?.name : null,
                        senderColor: sender?.color,
                      );
                    },
                  ),
          ),
          _Composer(controller: _controller, onSend: _send),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  maxLength: 4000,
                  buildCounter: (_,
                          {required currentLength,
                          required isFocused,
                          maxLength}) =>
                      null,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'پیام...',
                    fillColor: scheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide(color: scheme.primary, width: 1.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final hasText = value.text.trim().isNotEmpty;
                  return AnimatedScale(
                    scale: hasText ? 1 : 0.9,
                    duration: const Duration(milliseconds: 180),
                    child: IconButton.filled(
                      tooltip: 'ارسال',
                      onPressed: hasText ? onSend : null,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
