import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  (IconData, Color) _style(NotificationKind k) => switch (k) {
        NotificationKind.match => (Icons.search, AppColors.mint),
        NotificationKind.priceDrop => (Icons.favorite_border, AppColors.blush),
        NotificationKind.payment => (Icons.check_circle_outline, AppColors.sand),
        NotificationKind.message => (Icons.chat_bubble_outline, AppColors.mint),
        NotificationKind.interest => (Icons.shopping_bag_outlined, AppColors.blush),
        NotificationKind.sold => (Icons.sell_outlined, AppColors.sand),
      };

  @override
  Widget build(BuildContext context) {
    final items = MockData.notifications;
    final hasUnread = items.any((n) => n.unread);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), actions: [
        if (hasUnread)
          TextButton(
            onPressed: () => setState(() { for (final n in items) { n.unread = false; } }),
            child: const Text('Read all', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w800)),
          ),
      ]),
      body: items.isEmpty
          ? const EmptyState(icon: Icons.notifications_none, title: 'Nothing new', body: 'Matches, messages and payment updates will appear here.')
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = items[i];
                final (icon, bg) = _style(n.kind);
                return InkWell(
                  onTap: () => setState(() => n.unread = false),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 20, color: AppColors.greenDark)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(n.title, style: TextStyle(fontWeight: n.unread ? FontWeight.w800 : FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(n.body, style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.35)),
                      ])),
                      const SizedBox(width: 8),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(n.time, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                        if (n.unread) const Padding(padding: EdgeInsets.only(top: 6), child: CircleAvatar(radius: 4, backgroundColor: AppColors.green)),
                      ]),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
