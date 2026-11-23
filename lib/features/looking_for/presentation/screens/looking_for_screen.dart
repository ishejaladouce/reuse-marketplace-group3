
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/looking_for_request_model.dart';
import '../providers/looking_for_providers.dart';
import 'create_edit_request_screen.dart';
import 'my_requests_screen.dart';

class LookingForScreen extends ConsumerStatefulWidget {
  const LookingForScreen({super.key});

  @override
  ConsumerState<LookingForScreen> createState() =>
      _LookingForScreenState();
}

class _LookingForScreenState extends ConsumerState<LookingForScreen> {
  String _search = '';
  String _category = 'All';

  final _categories = [
    'All',
    'Electronics',
    'Fashion',
    'Furniture',
    'Books',
    'Home',
    'Sports',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(
      filteredLookingForRequestsProvider(
        LookingForFilter(
          searchQuery: _search,
          category: _category,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Looking For'),
        actions: [
          IconButton(
            tooltip: 'My Requests',
            icon: const Icon(Icons.list_alt_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyRequestsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateEditRequestScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Post Request'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help someone find what they need',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (value) {
                    setState(() => _search = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search requests...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];

                      return ChoiceChip(
                        label: Text(category),
                        selected: _category == category,
                        onSelected: (_) {
                          setState(() => _category = category);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: requests.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Could not load requests: $error'),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text('No matching requests found.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return LookingForRequestCard(request: items[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LookingForRequestCard extends StatelessWidget {
  final LookingForRequestModel request;

  const LookingForRequestCard({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String budgetText;

    if (request.minBudget != null && request.maxBudget != null) {
      budgetText =
          '${request.currency} ${request.minBudget!.toStringAsFixed(0)}'
          ' - ${request.maxBudget!.toStringAsFixed(0)}';
    } else if (request.maxBudget != null) {
      budgetText =
          'Up to ${request.currency} '
          '${request.maxBudget!.toStringAsFixed(0)}';
    } else if (request.minBudget != null) {
      budgetText =
          'From ${request.currency} '
          '${request.minBudget!.toStringAsFixed(0)}';
    } else {
      budgetText = 'Budget flexible';
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Chip(label: Text('WANTED')),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              request.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(label: Text(request.category)),
                Chip(label: Text(request.preferredCondition)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              budgetText,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 5),
                Expanded(child: Text(request.location)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
