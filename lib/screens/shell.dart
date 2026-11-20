import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'checkout_screen.dart';
import 'community_screen.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import 'orders_screen.dart';
import 'review_screen.dart';
import 'settings_screen.dart';

/// Bottom-nav shell from the information architecture:
/// Home | Explore | Sell (+) | Messages | Profile.
/// Home, Explore and Sell are placeholders for teammates' screens; Messages and Profile are wired up.
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _HomePlaceholder(),
      const _Placeholder('Explore', 'Search, filters and Looking For belong here.'),
      const _Placeholder('Sell', 'Create listing flow belongs here.'),
      const MessagesScreen(),
      const _ProfileMenu(),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.mint,
          labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppColors.green), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.search), label: 'Explore'),
            NavigationDestination(icon: Icon(Icons.add_circle, color: AppColors.green, size: 34), label: 'Sell'),
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble, color: AppColors.green), label: 'Messages'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppColors.green), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title, body;
  const _Placeholder(this.title, this.body);
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: EmptyState(icon: Icons.construction_outlined, title: '$title (teammate screen)', body: body),
      );
}

/// Home placeholder with shortcuts so every one of Michaella's screens can be opened while the rest is built.
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();
  void _open(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Reuse', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w800, fontSize: 24)),
          actions: [IconButton(icon: const Icon(Icons.notifications_none), onPressed: () => _open(context, const NotificationsScreen()))],
        ),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(18)),
            child: const Text('Good things deserve a second home.', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
          ),
          const SectionLabel('Shortcuts to the screens built here'),
          for (final (label, icon, page) in <(String, IconData, Widget)>[
            ('Checkout', Icons.lock_outline, const CheckoutScreen()),
            ('My orders', Icons.receipt_long_outlined, const OrdersScreen()),
            ('Notifications', Icons.notifications_none, const NotificationsScreen()),
            ('Community', Icons.groups_outlined, const CommunityScreen()),
            ('Rating and review', Icons.star_outline, const ReviewScreen()),
            ('Settings', Icons.settings_outlined, const SettingsScreen()),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(onTap: () => _open(context, page), child: Row(children: [Icon(icon, color: AppColors.green), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))), const Icon(Icons.chevron_right, color: AppColors.muted)])),
            ),
        ]),
      );
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();
  void _open(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const AppCard(child: Row(children: [
            Avatar('Amina N.', size: 52),
            SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Amina N.', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              SizedBox(height: 4),
              Pill('Verified account'),
            ]),
          ])),
          const SectionLabel('Marketplace'),
          AppCard(padding: EdgeInsets.zero, child: Column(children: [
            for (final (label, icon, page) in <(String, IconData, Widget)>[
              ('Purchases and sales', Icons.receipt_long_outlined, const OrdersScreen()),
              ('Reviews', Icons.star_outline, const ReviewScreen()),
              ('Community requests', Icons.groups_outlined, const CommunityScreen()),
              ('Notifications', Icons.notifications_none, const NotificationsScreen()),
              ('Settings', Icons.settings_outlined, const SettingsScreen()),
            ])
              ListTile(leading: Icon(icon, color: AppColors.green), title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)), trailing: const Icon(Icons.chevron_right, color: AppColors.muted), onTap: () => _open(context, page)),
          ])),
        ]),
      );
}
