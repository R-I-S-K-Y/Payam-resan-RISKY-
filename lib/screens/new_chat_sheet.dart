import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/avatar.dart';
import 'chat_screen.dart';

/// انتخاب عضو (یک نفر: گفتگوی دونفره، چند نفر: گروه) و ساخت گفتگو.
Future<void> showNewChatSheet(BuildContext context) async {
  final app = AppScope.of(context);
  final chat = await showModalBottomSheet<Chat>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _NewChatSheet(),
  );
  if (chat != null && context.mounted) {
    app.openChat(chat);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ChatScreen(chat: chat)),
    );
  }
}

class _NewChatSheet extends StatefulWidget {
  const _NewChatSheet();

  @override
  State<_NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends State<_NewChatSheet> {
  final Set<String> _selected = <String>{};
  final TextEditingController _name = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final app = AppScope.of(context);
    final isGroup = _selected.length > 1;
    final title = _name.text.trim();
    if (isGroup && title.isEmpty) {
      setState(() => _error = 'برای گروه یک نام بنویسید');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final chat = await app.createChat(
        title: isGroup ? title : '',
        memberIds: _selected.toList(),
        isGroup: isGroup,
      );
      if (!mounted) return;
      if (chat == null) {
        setState(() {
          _busy = false;
          _error = 'ساخت گفتگو انجام نشد';
        });
        return;
      }
      Navigator.of(context).pop(chat);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'ساخت گفتگو انجام نشد';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final others = app.members.where((m) => m.id != app.me.id).toList();
    final isGroup = _selected.length > 1;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'گفتگوی جدید',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'یک نفر را برای گفتگوی دونفره یا چند نفر را برای ساخت گروه انتخاب کنید.',
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.6),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: others.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'عضو دیگری پیدا نشد. بعد از اینکه بقیه‌ی خانواده یک‌بار وارد اپ شوند، اینجا دیده می‌شوند.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        height: 1.7,
                      ),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: [
                      for (final m in others)
                        CheckboxListTile(
                          value: _selected.contains(m.id),
                          onChanged: _busy
                              ? null
                              : (v) => setState(() {
                                    if (v ?? false) {
                                      _selected.add(m.id);
                                    } else {
                                      _selected.remove(m.id);
                                    }
                                  }),
                          secondary: Avatar(
                            label: m.name,
                            color: m.color,
                            radius: 20,
                          ),
                          title: Text(m.name),
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                    ],
                  ),
          ),
          if (isGroup) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _name,
              maxLength: 40,
              decoration: const InputDecoration(
                labelText: 'نام گروه',
                prefixIcon: Icon(Icons.groups_rounded),
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.error),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: (_selected.isEmpty || _busy) ? null : _create,
            child: _busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : Text(isGroup ? 'ساخت گروه' : 'شروع گفتگو'),
          ),
        ],
      ),
    );
  }
}
