import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/movie_provider.dart';
import '../widgets/movie_grid_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state_widget.dart';

class InfiniteMovieGrid extends StatefulWidget {
  final Function(int)? onMovieTap;

  const InfiniteMovieGrid({
    super.key,
    this.onMovieTap,
  });

  @override
  State<InfiniteMovieGrid> createState() => _InfiniteMovieGridState();
}

class _InfiniteMovieGridState extends State<InfiniteMovieGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      if (movieProvider.hasMorePages && !movieProvider.isLoadingMore) {
        movieProvider.loadMoreMovies();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        // Show loading indicator for initial load
        if (movieProvider.isInitialLoading) {
          return const Center(
            child: LoadingIndicator(),
          );
        }

        // Show error state
        if (movieProvider.error != null && movieProvider.filteredMovies.isEmpty) {
          return CustomErrorWidget(
            error: movieProvider.error!,
            onRetry: () => movieProvider.refresh(),
          );
        }

        // Show empty state
        if (movieProvider.filteredMovies.isEmpty && !movieProvider.isLoading) {
          return EmptyStateWidget(
            hasActiveFilters: movieProvider.hasActiveFilters,
            onClearFilters: () => movieProvider.clearFilters(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => movieProvider.refresh(),
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: movieProvider.filteredMovies.length + 
                       (movieProvider.hasMorePages ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom for pagination
              if (index == movieProvider.filteredMovies.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: LoadingIndicator(),
                  ),
                );
              }

              final movie = movieProvider.filteredMovies[index];
              return MovieGridCard(
                movie: movie,
                onTap: () {
                  if (widget.onMovieTap != null) {
                    widget.onMovieTap!(movie.id);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
