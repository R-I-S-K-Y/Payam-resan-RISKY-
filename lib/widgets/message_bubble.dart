import 'package:flutter/material.dart';

import '../models/models.dart';
import '../utils/fa.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.senderName,
    this.senderColor,
  });

  final Message message;
  final bool isMine;
  final String? senderName;
  final Color? senderColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isMine ? scheme.primaryContainer : scheme.surfaceContainerHigh;
    final fg = isMine ? scheme.onPrimaryContainer : scheme.onSurface;
    final metaColor = fg.withValues(alpha: 0.6);

    const big = Radius.circular(20);
    const small = Radius.circular(6);
    final radius = BorderRadiusDirectional.only(
      topStart: big,
      topEnd: big,
      bottomStart: isMine ? small : big,
      bottomEnd: isMine ? big : small,
    );

    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 14),
          child: child,
        ),
      ),
      child: Align(
        alignment: isMine
            ? AlignmentDirectional.centerStart
            : AlignmentDirectional.centerEnd,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
          decoration: BoxDecoration(color: bg, borderRadius: radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (senderName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    senderName!,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: senderColor ?? scheme.primary,
                    ),
                  ),
                ),
              Text(
                message.text,
                style: TextStyle(fontSize: 15.5, height: 1.5, color: fg),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeLabel(message.time),
                    style: TextStyle(fontSize: 11, color: metaColor),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    _Ticks(status: message.status, base: metaColor),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ticks extends StatelessWidget {
  const _Ticks({required this.status, required this.base});

  final MessageStatus status;
  final Color base;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final IconData icon;
    Color color = base;
    switch (status) {
      case MessageStatus.sending:
        icon = Icons.schedule_rounded;
      case MessageStatus.sent:
        icon = Icons.done_rounded;
      case MessageStatus.delivered:
        icon = Icons.done_all_rounded;
      case MessageStatus.read:
        icon = Icons.done_all_rounded;
        color = scheme.tertiary;
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: Icon(icon, key: ValueKey(status), size: 16, color: color),
    );
  }
}
