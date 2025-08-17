import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;
  final String? customMessage;

  const EmptyStateWidget({
    super.key,
    this.hasActiveFilters = false,
    this.onClearFilters,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasActiveFilters ? Icons.filter_list_off : Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilters ? 'No movies found' : 'No movies available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              customMessage ?? _getDefaultMessage(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (hasActiveFilters && onClearFilters != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getDefaultMessage() {
    if (hasActiveFilters) {
      return 'Try adjusting your search or filters to find more movies.';
    }
    return 'There are no movies available at the moment. Please try again later.';
  }
}
