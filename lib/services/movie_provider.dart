import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'movie_service.dart';

class MovieProvider extends ChangeNotifier {
  final MovieService _movieService = MovieService();
  
  List<Movie> _topRatedMovies = [];
  List<Movie> _moviesByGenre = [];
  Movie? _selectedMovie;
  bool _isLoading = false;
  String? _error;
  int _selectedGenreId = 28; // Default to Action

  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get moviesByGenre => _moviesByGenre;
  Movie? get selectedMovie => _selectedMovie;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedGenreId => _selectedGenreId;

  Future<void> loadTopRatedMovies() async {
    _setLoading(true);
    try {
      _topRatedMovies = await _movieService.getTopRatedMovies();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoviesByGenre(int genreId) async {
    _selectedGenreId = genreId;
    _setLoading(true);
    try {
      _moviesByGenre = await _movieService.getMoviesByGenre(genreId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMovieDetails(int movieId) async {
    _setLoading(true);
    try {
      _selectedMovie = await _movieService.getMovieDetails(movieId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
