import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int tab = 0; // 0 All, 1 Buying, 2 Selling

  @override
  Widget build(BuildContext context) {
    final list = MockData.conversations.where((c) => tab == 0 || (tab == 1 ? c.buying : !c.buying)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
      ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Segmented(options: const ['All', 'Buying', 'Selling'], selected: tab, onChanged: (i) => setState(() => tab = i)),
        ),
        Expanded(
          child: list.isEmpty
              ? const EmptyState(icon: Icons.chat_bubble_outline, title: 'No conversations yet', body: 'Message a seller from any listing to start chatting.')
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final c = list[i];
                    return InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: c))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(children: [
                          Avatar(c.name),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                              Text(c.item, style: const TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(c.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                            ]),
                          ),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text(c.time, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                            const SizedBox(height: 6),
                            if (c.unread > 0)
                              CircleAvatar(radius: 9, backgroundColor: AppColors.green, child: Text('${c.unread}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
                          ]),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
