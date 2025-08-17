import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/movie_provider.dart';
import '../models/genre.dart';
import '../widgets/movie_card.dart';
import '../widgets/infinite_movie_grid.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      movieProvider.initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.movie, size: 28),
            const SizedBox(width: 8),
            const Text(
              'Movie Reviews',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (movieProvider.isInitialLoading) {
            return const Center(
              child: LoadingIndicator(size: 48.0),
            );
          }

          if (movieProvider.error != null && 
              movieProvider.topRatedMovies.isEmpty && 
              movieProvider.filteredMovies.isEmpty) {
            return CustomErrorWidget(
              error: movieProvider.error!,
              onRetry: () => movieProvider.refresh(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => movieProvider.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar Section
                  _buildSearchBar(movieProvider),
                  const SizedBox(height: 24),
                  
                  // Top Rated Movies Section
                  _buildTopRatedSection(movieProvider),
                  const SizedBox(height: 32),
                  
                  // Genre Categories Section
                  _buildGenreCategoriesSection(movieProvider),
                  const SizedBox(height: 16),
                  
                  // Year Filter Section
                  _buildYearFilterSection(movieProvider),
                  const SizedBox(height: 24),
                  
                  // Movies by Selected Genre (with search results)
                  _buildMoviesByGenreSection(movieProvider),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(MovieProvider movieProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            movieProvider.setSearchQuery(value);
          },
          decoration: InputDecoration(
            hintText: 'Search movies...',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[600],
              size: 24,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      movieProvider.setSearchQuery('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRatedSection(MovieProvider movieProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Top Rated Movies',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        SizedBox(
          height: 320,
          child: movieProvider.isLoading && movieProvider.topRatedMovies.isEmpty
              ? const Center(
                  child: LoadingIndicator(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: movieProvider.topRatedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = movieProvider.topRatedMovies[index];
                    return MovieCard(
                      movie: movie,
                      onTap: () => _navigateToMovieDetail(movie.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGenreCategoriesSection(MovieProvider movieProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: GenreConstants.genres.length,
            itemBuilder: (context, index) {
              final genre = GenreConstants.genres[index];
              final isSelected = genre.id == movieProvider.selectedGenreId;
              
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(
                    genre.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.deepPurple,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    movieProvider.setGenreFilter(genre.id);
                    movieProvider.clearFilters(); // Clear search and year filters when changing genre
                    _searchController.clear();
                  },
                  selectedColor: Colors.deepPurple,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.deepPurple.withOpacity(0.1),
                  elevation: 2,
                  pressElevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearFilterSection(MovieProvider movieProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Filter by Year',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: MovieProvider.years.length + 1, // +1 for "All Years" option
            itemBuilder: (context, index) {
              if (index == 0) {
                // "All Years" option
                final isSelected = movieProvider.selectedYear == null;
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: const Text(
                      'All Years',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      movieProvider.setYearFilter(null);
                    },
                    selectedColor: Colors.orange,
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    elevation: 2,
                    pressElevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }
              
              final year = MovieProvider.years[index - 1];
              final isSelected = movieProvider.selectedYear == year;
              
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(
                    year,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.orange,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    movieProvider.setYearFilter(selected ? year : null);
                  },
                  selectedColor: Colors.orange,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  elevation: 2,
                  pressElevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoviesByGenreSection(MovieProvider movieProvider) {
    final selectedGenre = GenreConstants.genres.firstWhere(
      (genre) => genre.id == movieProvider.selectedGenreId,
      orElse: () => const Genre(id: 0, name: 'Unknown'),
    );

    final hasActiveFilters = movieProvider.searchQuery.isNotEmpty || 
                           movieProvider.selectedYear != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasActiveFilters 
                      ? 'Search Results' 
                      : '${selectedGenre.name} Movies',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: () {
                    movieProvider.clearFilters();
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear Filters'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Use the new InfiniteMovieGrid for pagination
        SizedBox(
          height: 600, // Fixed height for the grid
          child: InfiniteMovieGrid(
            onMovieTap: (movieId) => _navigateToMovieDetail(movieId),
          ),
        ),
      ],
    );
  }

  void _navigateToMovieDetail(int movieId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(movieId: movieId),
      ),
    );
  }
}
