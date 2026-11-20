import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'checkout_screen.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  const ChatScreen({super.key, required this.conversation});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  late final List<ChatMessage> _messages =
      List.of(MockData.chats[widget.conversation.id] ?? const []);

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    final now = TimeOfDay.now();
    setState(() => _messages.add(ChatMessage(t, '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}', mine: true)));
    _ctrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80, duration: const Duration(milliseconds: 200), curve: Curves.easeOut));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conversation;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(children: [
          Avatar(c.name, size: 36),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            Text(c.item, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ]),
        ]),
      ),
      body: Column(children: [
        if (c.buying)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: AppCard(
              color: AppColors.mint,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
              child: const Row(children: [
                Icon(Icons.lock_outline, color: AppColors.green, size: 18),
                SizedBox(width: 10),
                Expanded(child: Text('Agreed on a price? Pay in Reuse so your money is held until the item arrives.', style: TextStyle(fontSize: 12.5, height: 1.35))),
                Icon(Icons.chevron_right, color: AppColors.green),
              ]),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: _messages.length,
            itemBuilder: (_, i) {
              final m = _messages[i];
              return Align(
                alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: m.mine ? AppColors.green : Colors.white,
                    border: m.mine ? null : Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(m.mine ? 16 : 4),
                      bottomRight: Radius.circular(m.mine ? 4 : 16),
                    ),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(m.text, style: TextStyle(color: m.mine ? Colors.white : AppColors.ink, height: 1.35)),
                    const SizedBox(height: 3),
                    Text(m.time, style: TextStyle(fontSize: 10, color: m.mine ? Colors.white70 : AppColors.muted)),
                  ]),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Row(children: [
              Expanded(child: TextField(controller: _ctrl, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'Write a message'))),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: AppColors.green, minimumSize: const Size(48, 48)),
                onPressed: _send,
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
