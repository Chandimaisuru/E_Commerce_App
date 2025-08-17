import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/genre.dart';
import 'movie_service.dart';

class MovieProvider extends ChangeNotifier {
  final MovieService _movieService = MovieService();
  
  // Movie lists
  List<Movie> _topRatedMovies = [];
  List<Movie> _filteredMovies = [];
  
  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalResults = 0;
  bool _hasMorePages = true;
  
  // Loading states
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isInitialLoading = false;
  
  // Error state
  String? _error;
  
  // Filter states
  int? _selectedGenreId;
  String? _selectedYear;
  String _searchQuery = '';
  
  // Selected movie
  Movie? _selectedMovie;
  
  // Available years for filtering (from 2024 to 1950)
  static const List<String> availableYears = [
    '2024', '2023', '2022', '2021', '2020', '2019', '2018', '2017', '2016', '2015',
    '2014', '2013', '2012', '2011', '2010', '2009', '2008', '2007', '2006', '2005',
    '2004', '2003', '2002', '2001', '2000', '1999', '1998', '1997', '1996', '1995',
    '1994', '1993', '1992', '1991', '1990', '1989', '1988', '1987', '1986', '1985',
    '1984', '1983', '1982', '1981', '1980', '1979', '1978', '1977', '1976', '1975',
    '1974', '1973', '1972', '1971', '1970', '1969', '1968', '1967', '1966', '1965',
    '1964', '1963', '1962', '1961', '1960', '1959', '1958', '1957', '1956', '1955',
    '1954', '1953', '1952', '1951', '1950'
  ];

  // Getters
  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get filteredMovies => _filteredMovies;
  Movie? get selectedMovie => _selectedMovie;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isInitialLoading => _isInitialLoading;
  String? get error => _error;
  int? get selectedGenreId => _selectedGenreId;
  String? get selectedYear => _selectedYear;
  String get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalResults => _totalResults;
  bool get hasMorePages => _hasMorePages;
  static List<String> get years => availableYears;

  // Initialize the provider
  Future<void> initialize() async {
    _isInitialLoading = true;
    notifyListeners();
    
    try {
      await Future.wait([
        loadTopRatedMovies(),
        loadMovies(), // Load initial movies
      ]);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  // Load top rated movies
  Future<void> loadTopRatedMovies() async {
    try {
      final result = await _movieService.getTopRatedMovies(page: 1);
      _topRatedMovies = result['movies'];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load movies with current filters
  Future<void> loadMovies({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _filteredMovies.clear();
      _hasMorePages = true;
    }

    if (!_hasMorePages || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _movieService.getMovies(
        page: _currentPage,
        genreId: _selectedGenreId,
        year: _selectedYear,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      final newMovies = result['movies'] as List<Movie>;
      _totalPages = result['totalPages'];
      _totalResults = result['totalResults'];
      
      if (refresh) {
        _filteredMovies = newMovies;
      } else {
        _filteredMovies.addAll(newMovies);
      }
      
      _currentPage++;
      _hasMorePages = _currentPage <= _totalPages;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load more movies (for infinite scroll)
  Future<void> loadMoreMovies() async {
    if (!_hasMorePages || _isLoadingMore) return;
    await loadMovies();
  }

  // Set genre filter
  Future<void> setGenreFilter(int? genreId) async {
    if (_selectedGenreId == genreId) return;
    
    _selectedGenreId = genreId;
    _isLoading = true;
    notifyListeners();
    
    try {
      await loadMovies(refresh: true);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set year filter
  Future<void> setYearFilter(String? year) async {
    if (_selectedYear == year) return;
    
    _selectedYear = year;
    _isLoading = true;
    notifyListeners();
    
    try {
      await loadMovies(refresh: true);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set search query
  Future<void> setSearchQuery(String query) async {
    if (_searchQuery == query) return;
    
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();
    
    try {
      if (query.isEmpty) {
        // If search is cleared, load movies without search
        await loadMovies(refresh: true);
      } else {
        // If search has content, load movies with search
        await loadMovies(refresh: true);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all filters
  Future<void> clearFilters() async {
    _selectedGenreId = null;
    _selectedYear = null;
    _searchQuery = '';
    _isLoading = true;
    notifyListeners();
    
    try {
      await loadMovies(refresh: true);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load movie details
  Future<void> loadMovieDetails(int movieId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _selectedMovie = await _movieService.getMovieDetails(movieId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await Future.wait([
        loadTopRatedMovies(),
        loadMovies(refresh: true),
      ]);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if any filters are active
  bool get hasActiveFilters {
    return _selectedGenreId != null || 
           _selectedYear != null || 
           _searchQuery.isNotEmpty;
  }

  // Get current filter description
  String get filterDescription {
    final parts = <String>[];
    
    if (_selectedGenreId != null) {
      final genre = GenreConstants.genres.firstWhere(
        (g) => g.id == _selectedGenreId,
        orElse: () => const Genre(id: 0, name: 'Unknown'),
      );
      parts.add(genre.name);
    }
    
    if (_selectedYear != null) {
      parts.add('Year: $_selectedYear');
    }
    
    if (_searchQuery.isNotEmpty) {
      parts.add('Search: "$_searchQuery"');
    }
    
    return parts.isEmpty ? 'All Movies' : parts.join(' • ');
  }

  // Legacy methods for backward compatibility
  List<Movie> get moviesByGenre => _filteredMovies;
  int get selectedGenreIdLegacy => _selectedGenreId ?? 28;
  
  Future<void> loadMoviesByGenre(int genreId) async {
    await setGenreFilter(genreId);
  }
  
  void setSelectedYear(String? year) {
    setYearFilter(year);
  }
}
