import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/review_model.dart';
import '../providers/review_provider.dart';
import '../widgets/review_card.dart';

class SellerReviewsScreen extends ConsumerWidget {
  const SellerReviewsScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(sellerReviewsProvider(sellerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: reviews.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => const Center(child: Text('Could not load reviews. Please try again.')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No reviews yet.'));
          }
          final average = averageRating(list);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    Text(average.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold)),
                    StarRating(rating: average, size: 26),
                    const SizedBox(height: 6),
                    Text(
                      'Based on ${list.length} review${list.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              for (final review in list) ReviewCard(review: review),
            ],
          );
        },
      ),
    );
  }
}