import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ReviewScreen extends StatefulWidget {
  final String sellerName;
  final VoidCallback? onSubmitted;
  const ReviewScreen({super.key, this.sellerName = 'Sarah M.', this.onSubmitted});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int stars = 0;
  final tags = <String>{};
  final note = TextEditingController();
  static const options = ['Item as described', 'Good communication', 'On time', 'Friendly'];
  static const labels = ['Tap a star', 'Poor', 'Fair', 'Good', 'Very good', 'Excellent'];

  void _submit() {
    widget.onSubmitted?.call();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted. Thank you for helping the community.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
          Center(child: Column(children: [
            Avatar(widget.sellerName, size: 64),
            const SizedBox(height: 8),
            Text(widget.sellerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Pill('Verified seller'),
          ])),
          const SizedBox(height: 20),
          AppCard(
            color: AppColors.cream,
            child: Column(children: [
              const Text('How was your experience with this seller?', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Your review helps the community make more informed decisions.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: () => setState(() => stars = i),
                    icon: Icon(i <= stars ? Icons.star_rounded : Icons.star_outline_rounded, size: 38, color: i <= stars ? AppColors.star : AppColors.border),
                  ),
              ]),
              Text(labels[stars], style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
          ),
          const SectionLabel('What went well?'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in options)
              FilterChip(
                label: Text(t),
                selected: tags.contains(t),
                showCheckmark: false,
                onSelected: (v) => setState(() => v ? tags.add(t) : tags.remove(t)),
                selectedColor: AppColors.green,
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.border),
                labelStyle: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tags.contains(t) ? Colors.white : AppColors.ink),
              ),
          ]),
          const SectionLabel('Write a review (optional)'),
          TextField(controller: note, maxLines: 4, decoration: const InputDecoration(hintText: 'Tell others how the deal went')),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: stars == 0 ? null : _submit, child: const Text('Submit review')),
        ]),
      );
}
