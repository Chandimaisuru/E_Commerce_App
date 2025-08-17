import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/movie_provider.dart';
import '../models/genre.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_grid_card.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      movieProvider.loadTopRatedMovies();
      movieProvider.loadMoviesByGenre(28); // Load Action movies by default
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movie Review App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (movieProvider.isLoading && movieProvider.topRatedMovies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (movieProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${movieProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      movieProvider.clearError();
                      movieProvider.loadTopRatedMovies();
                      movieProvider.loadMoviesByGenre(movieProvider.selectedGenreId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await movieProvider.loadTopRatedMovies();
              await movieProvider.loadMoviesByGenre(movieProvider.selectedGenreId);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Rated Movies Section
                  _buildTopRatedSection(movieProvider),
                  const SizedBox(height: 24),
                  
                  // Genre Categories Section
                  _buildGenreCategoriesSection(movieProvider),
                  const SizedBox(height: 16),
                  
                  // Movies by Selected Genre
                  _buildMoviesByGenreSection(movieProvider),
                ],
              ),
            ),
          );
        },
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: movieProvider.isLoading && movieProvider.topRatedMovies.isEmpty
              ? const Center(child: CircularProgressIndicator())
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
                  label: Text(genre.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    movieProvider.loadMoviesByGenre(genre.id);
                  },
                  selectedColor: Colors.deepPurple.withOpacity(0.2),
                  checkmarkColor: Colors.deepPurple,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${selectedGenre.name} Movies',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (movieProvider.isLoading && movieProvider.moviesByGenre.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: movieProvider.moviesByGenre.length,
            itemBuilder: (context, index) {
              final movie = movieProvider.moviesByGenre[index];
              return MovieGridCard(
                movie: movie,
                onTap: () => _navigateToMovieDetail(movie.id),
              );
            },
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
