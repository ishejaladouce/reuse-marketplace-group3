import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Community feed of "Looking For" requests + the form to post one.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    final posts = MockData.posts;
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        onPressed: () async {
          final post = await Navigator.push<LookingForPost>(context, MaterialPageRoute(builder: (_) => const LookingForRequestScreen()));
          if (post != null) setState(() => MockData.posts.insert(0, post));
        },
        icon: const Icon(Icons.add),
        label: const Text('Post request', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        itemCount: posts.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          if (i == 0) return const TrustBanner('Can\'t find something? Post what you need and sellers will contact you when they list a match.');
          final p = posts[i - 1];
          return AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Avatar(p.author, size: 34),
                const SizedBox(width: 10),
                Expanded(child: Text(p.author, style: const TextStyle(fontWeight: FontWeight.w800))),
                Text(p.time, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ]),
              const SizedBox(height: 10),
              Text('Looking for ${p.item}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                Pill(p.category),
                Pill('Up to ${rwf(p.budget)}', bg: AppColors.sand, fg: AppColors.ink),
                Pill(p.location, bg: AppColors.cream, fg: AppColors.muted),
                Pill(p.condition, bg: AppColors.cream, fg: AppColors.muted),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Text(p.replies == 0 ? 'No offers yet' : '${p.replies} offers', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('I have this', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w800))),
              ]),
            ]),
          );
        },
      ),
    );
  }
}

class LookingForRequestScreen extends StatefulWidget {
  const LookingForRequestScreen({super.key});
  @override
  State<LookingForRequestScreen> createState() => _LookingForRequestScreenState();
}

class _LookingForRequestScreenState extends State<LookingForRequestScreen> {
  final item = TextEditingController();
  final budget = TextEditingController();
  final location = TextEditingController(text: 'Kigali');
  String category = 'Clothing';
  String condition = 'Like new';
  static const categories = ['Furniture', 'Electronics', 'Clothing', 'Books', 'Home'];
  static const conditions = ['New', 'Like new', 'Good', 'Fair'];

  bool get valid => item.text.trim().isNotEmpty && int.tryParse(budget.text.trim()) != null;

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(top: 14, bottom: 6), child: Text(t, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.muted)));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
          Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.search, color: AppColors.ink)),
          const SizedBox(height: 12),
          const Text('Let the community help you find it.', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.15)),
          const SizedBox(height: 6),
          const Text('Tell sellers what you are looking for and we will notify you when a matching item is listed.', style: TextStyle(color: AppColors.muted, height: 1.4)),
          _label('What are you looking for?'),
          TextField(controller: item, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'e.g. Brown leggings')),
          _label('Category'),
          DropdownButtonFormField<String>(
            value: category,
            items: [for (final c in categories) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) => setState(() => category = v!),
          ),
          _label('Budget (RWF)'),
          TextField(controller: budget, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: '30000')),
          _label('Location'),
          TextField(controller: location, decoration: const InputDecoration(hintText: 'Kigali')),
          _label('Preferred condition'),
          DropdownButtonFormField<String>(
            value: condition,
            items: [for (final c in conditions) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) => setState(() => condition = v!),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: valid
                ? () => Navigator.pop(context, LookingForPost('You', item.text.trim(), category, int.parse(budget.text.trim()), location.text.trim(), condition, 'Now', 0))
                : null,
            child: const Text('Post request'),
          ),
        ]),
      );
}
