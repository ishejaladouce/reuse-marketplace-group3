import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/review_model.dart';
import '../providers/review_provider.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _comment = TextEditingController();
  final _rating = ValueNotifier<int>(0);
  final _ratingError = ValueNotifier<bool>(false);
  final _tags = ValueNotifier<Set<String>>({});

  @override
  void dispose() {
    _comment.dispose();
    _rating.dispose();
    _ratingError.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _submit(ReviewableOrder order) async {
    final ratingMissing = _rating.value == 0;
    _ratingError.value = ratingMissing;
    final formIsValid = _formKey.currentState!.validate();
    if (ratingMissing || !formIsValid) return;

    final sent = await ref.read(submitReviewControllerProvider.notifier).submit(
          order: order,
          rating: _rating.value,
          comment: _comment.text,
          tags: _tags.value.toList(),
        );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(sent ? 'Thank you for your review!' : 'Could not send your review. Please try again.'),
    ));
    if (sent) {
      ref.invalidate(reviewEligibilityProvider(order.orderId));
      context.pushReplacement('/users/${order.sellerId}/reviews');
    }
  }

  @override
  Widget build(BuildContext context) {
    final eligibility = ref.watch(reviewEligibilityProvider(widget.orderId));
    final isSending = ref.watch(submitReviewControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Leave a review')),
      body: eligibility.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => const _Message(
          icon: Icons.error_outline,
          text: 'Could not load this order. Please try again.',
        ),
        data: (result) {
          if (!result.canReview) {
            return _Message(icon: Icons.info_outline, text: result.reason!);
          }
          final order = result.order!;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('How was your experience?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(order.itemTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 16),
                ValueListenableBuilder<int>(
                  valueListenable: _rating,
                  builder: (context, rating, _) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 1; i <= 5; i++)
                        IconButton(
                          tooltip: '$i star${i == 1 ? '' : 's'}',
                          onPressed: () {
                            _rating.value = i;
                            _ratingError.value = false;
                          },
                          icon: Icon(
                            i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 40,
                            color: Colors.amber,
                          ),
                        ),
                    ],
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _ratingError,
                  builder: (context, showError, _) => showError
                      ? const Text('Please choose a rating',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFFB3261E)))
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),
                const Text('What went well?', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ValueListenableBuilder<Set<String>>(
                  valueListenable: _tags,
                  builder: (context, selected, _) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in reviewTags.entries)
                        FilterChip(
                          label: Text(entry.value),
                          selected: selected.contains(entry.key),
                          onSelected: (isOn) {
                            final next = {...selected};
                            isOn ? next.add(entry.key) : next.remove(entry.key);
                            _tags.value = next;
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _comment,
                  maxLines: 4,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Your comment',
                    hintText: 'Tell other buyers about this seller',
                    alignLabelWithHint: true,
                  ),
                  validator: Review.validateComment,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: isSending ? null : () => _submit(order),
                  child: isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send review'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}