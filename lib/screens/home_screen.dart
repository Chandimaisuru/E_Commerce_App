import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/movie_provider.dart';
import '../models/genre.dart';
import '../models/movie.dart';
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
  final FocusNode _searchFocusNode = FocusNode();
  List<Movie> _searchSuggestions = [];
  bool _showSuggestions = false;
  Timer? _debounceTimer;

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
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
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
      body: GestureDetector(
        onTap: () {
          // Hide suggestions when tapping outside
          if (_showSuggestions) {
            setState(() {
              _showSuggestions = false;
            });
            _searchFocusNode.unfocus();
          }
        },
        child: Consumer<MovieProvider>(
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
      ),
    );
  }

  void _onSearchChanged(String query, MovieProvider movieProvider) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Set search query for main results
    movieProvider.setSearchQuery(query);
    
    // Hide suggestions if query is empty
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _searchSuggestions.clear();
      });
      return;
    }
    
    // Debounce search suggestions
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (query.length >= 2) {
        try {
          final suggestions = await movieProvider.getSearchSuggestions(query);
          if (mounted) {
            setState(() {
              _searchSuggestions = suggestions;
              _showSuggestions = true;
            });
          }
        } catch (e) {
          // Handle error silently for suggestions
        }
      } else {
        setState(() {
          _showSuggestions = false;
          _searchSuggestions.clear();
        });
      }
    });
  }

  void _onSuggestionSelected(Movie movie, MovieProvider movieProvider) {
    // Hide suggestions
    setState(() {
      _showSuggestions = false;
      _searchSuggestions.clear();
    });
    
    // Remove focus from search field
    _searchFocusNode.unfocus();
    
    // Navigate to movie details page
    _navigateToMovieDetail(movie.id);
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _showSuggestions = false;
      _searchSuggestions.clear();
    });
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    movieProvider.clearFilters();
  }

  Widget _buildSearchBar(MovieProvider movieProvider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        children: [
          // Search Input Field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) {
                _onSearchChanged(value, movieProvider);
              },
              onTap: () {
                if (_searchController.text.isNotEmpty) {
                  setState(() {
                    _showSuggestions = true;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Search for movies...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey[600],
                  size: 24,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _onClearSearch,
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.deepPurple.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Suggestions Dropdown
          if (_showSuggestions && _searchSuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                maxHeight: 300,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _searchSuggestions.length,
                itemBuilder: (context, index) {
                  final movie = _searchSuggestions[index];
                  return _buildSuggestionItem(movie, movieProvider);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(Movie movie, MovieProvider movieProvider) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _onSuggestionSelected(movie, movieProvider);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Movie Poster
              Container(
                width: 40,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(
                    image: NetworkImage(
                      movie.posterPath.isNotEmpty
                          ? 'https://image.tmdb.org/t/p/w92${movie.posterPath}'
                          : 'https://via.placeholder.com/40x60/cccccc/666666?text=No+Image',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Movie Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      movie.titleWithYear,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Rating
              if (movie.voteAverage > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: GenreConstants.genres.length + 1, // +1 for "All Films" option
            itemBuilder: (context, index) {
              if (index == 0) {
                // "All Films" selectable option
                final isSelected = movieProvider.selectedGenreId == null;
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: _buildCategoryChip('All Films', isSelected, () {
                    movieProvider.setGenreFilter(null);
                  }),
                );
              }
              
              final genre = GenreConstants.genres[index - 1];
              final isSelected = genre.id == movieProvider.selectedGenreId;
              
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: _buildCategoryChip(genre.name, isSelected, () {
                  movieProvider.setGenreFilter(genre.id);
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearFilterSection(MovieProvider movieProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Filter by Year',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(
          height: 44,
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
                  child: _buildYearChip('All Years', isSelected, () {
                    movieProvider.setYearFilter(null);
                  }),
                );
              }
              
              final year = MovieProvider.years[index - 1];
              final isSelected = movieProvider.selectedYear == year;
              
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: _buildYearChip(year, isSelected, () {
                  movieProvider.setYearFilter(isSelected ? null : year);
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearChip(String label, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoviesByGenreSection(MovieProvider movieProvider) {
    final hasActiveFilters = movieProvider.searchQuery.isNotEmpty || 
                           movieProvider.selectedYear != null ||
                           movieProvider.selectedGenreId != null;

    String sectionTitle = 'All Movies';
    if (movieProvider.searchQuery.isNotEmpty) {
      sectionTitle = 'Search Results';
    } else if (movieProvider.selectedGenreId != null && movieProvider.selectedYear != null) {
      final selectedGenre = GenreConstants.genres.firstWhere(
        (genre) => genre.id == movieProvider.selectedGenreId,
        orElse: () => const Genre(id: 0, name: 'Unknown'),
      );
      sectionTitle = '${selectedGenre.name} Movies (${movieProvider.selectedYear})';
    } else if (movieProvider.selectedGenreId != null) {
      final selectedGenre = GenreConstants.genres.firstWhere(
        (genre) => genre.id == movieProvider.selectedGenreId,
        orElse: () => const Genre(id: 0, name: 'Unknown'),
      );
      sectionTitle = '${selectedGenre.name} Movies';
    } else if (movieProvider.selectedYear != null) {
      sectionTitle = 'Movies from ${movieProvider.selectedYear}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  sectionTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5,
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
