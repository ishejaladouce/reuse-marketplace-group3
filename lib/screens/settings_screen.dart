import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool matches = true, messages = true, priceDrops = true, payments = true, showPhone = false;

  Widget _switch(String title, String sub, bool v, ValueChanged<bool> on) => SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        value: v,
        onChanged: on,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
        subtitle: Text(sub, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      );

  Widget _tile(IconData icon, String title, {String? trailing, VoidCallback? onTap, Color? color}) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        leading: Icon(icon, color: color ?? AppColors.green),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: color)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (trailing != null) Text(trailing, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ]),
        onTap: onTap ?? () {},
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
          AppCard(child: Row(children: [
            const Avatar('Amina N.', size: 52),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Amina N.', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              SizedBox(height: 4),
              Pill('Verified account'),
            ])),
            TextButton(onPressed: () {}, child: const Text('Edit', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w800))),
          ])),
          const SectionLabel('Payment'),
          AppCard(padding: EdgeInsets.zero, child: Column(children: [
            _tile(Icons.phone_android, 'Mobile Money number', trailing: '+250 78X XXX 421'),
            const Divider(height: 1),
            _tile(Icons.receipt_long_outlined, 'Payment history'),
          ])),
          const SectionLabel('Notifications'),
          AppCard(padding: EdgeInsets.zero, child: Column(children: [
            _switch('Matches for my requests', 'When a listing fits what you are looking for', matches, (v) => setState(() => matches = v)),
            const Divider(height: 1),
            _switch('Messages', 'New chats and replies', messages, (v) => setState(() => messages = v)),
            const Divider(height: 1),
            _switch('Price drops', 'On items you saved', priceDrops, (v) => setState(() => priceDrops = v)),
            const Divider(height: 1),
            _switch('Payments and orders', 'Payment, delivery and release updates', payments, (v) => setState(() => payments = v)),
          ])),
          const SectionLabel('Privacy and safety'),
          AppCard(padding: EdgeInsets.zero, child: Column(children: [
            _switch('Show phone number on profile', 'Off by default. Chat keeps your number private', showPhone, (v) => setState(() => showPhone = v)),
            const Divider(height: 1),
            _tile(Icons.shield_outlined, 'Verification', trailing: 'Verified'),
            const Divider(height: 1),
            _tile(Icons.help_outline, 'Help and report a problem'),
          ])),
          const SectionLabel('Account'),
          AppCard(padding: EdgeInsets.zero, child: Column(children: [
            _tile(Icons.description_outlined, 'Terms and Privacy Policy'),
            const Divider(height: 1),
            _tile(Icons.logout, 'Log out', color: AppColors.danger, onTap: () {}),
          ])),
        ]),
      );
}
