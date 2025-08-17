import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey = 'e697e2f244416ee180c7971667767741';

  // Get movies with pagination and filtering support
  Future<Map<String, dynamic>> getMovies({
    int page = 1,
    int? genreId,
    String? year,
    String? searchQuery,
    String sortBy = 'popularity.desc',
  }) async {
    try {
      Uri uri;
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Search movies
        uri = Uri.parse('$baseUrl/search/movie?api_key=$apiKey&language=en-US&query=${Uri.encodeComponent(searchQuery)}&page=$page&include_adult=false');
      } else {
        // Discover movies with filters
        final queryParams = {
          'api_key': apiKey,
          'language': 'en-US',
          'sort_by': sortBy,
          'include_adult': 'false',
          'include_video': 'false',
          'page': page.toString(),
        };
        
        if (genreId != null) {
          queryParams['with_genres'] = genreId.toString();
        }
        
        if (year != null && year.isNotEmpty) {
          queryParams['primary_release_year'] = year;
        }
        
        uri = Uri.parse('$baseUrl/discover/movie').replace(queryParameters: queryParams);
      }

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        final totalPages = data['total_pages'] ?? 1;
        final totalResults = data['total_results'] ?? 0;
        
        final movies = results.map((json) => Movie.fromJson(json)).toList();
        
        return {
          'movies': movies,
          'totalPages': totalPages,
          'totalResults': totalResults,
          'currentPage': page,
        };
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get top rated movies with pagination
  Future<Map<String, dynamic>> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/top_rated?api_key=$apiKey&language=en-US&page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        final totalPages = data['total_pages'] ?? 1;
        final totalResults = data['total_results'] ?? 0;
        
        final movies = results.map((json) => Movie.fromJson(json)).toList();
        
        return {
          'movies': movies,
          'totalPages': totalPages,
          'totalResults': totalResults,
          'currentPage': page,
        };
      } else {
        throw Exception('Failed to load top rated movies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get movies by genre with pagination (kept for backward compatibility)
  Future<Map<String, dynamic>> getMoviesByGenre(int genreId, {int page = 1}) async {
    return getMovies(genreId: genreId, page: page);
  }

  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey&language=en-US'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Movie.fromJson(data);
      } else {
        throw Exception('Failed to load movie details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get available genres from TMDB API
  Future<List<Map<String, dynamic>>> getGenres() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/genre/movie/list?api_key=$apiKey&language=en-US'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final genres = data['genres'] as List;
        return genres.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load genres');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get movie videos (trailers, teasers, etc.)
  Future<List<Map<String, dynamic>>> getMovieVideos(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/$movieId/videos?api_key=$apiKey&language=en-US'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load movie videos');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get official trailer for a movie
  Future<String?> getOfficialTrailer(int movieId) async {
    try {
      final videos = await getMovieVideos(movieId);
      
      // Look for official trailer first, then any trailer
      final officialTrailer = videos.firstWhere(
        (video) => video['type'] == 'Trailer' && 
                   video['official'] == true &&
                   video['site'] == 'YouTube',
        orElse: () => videos.firstWhere(
          (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
          orElse: () => <String, dynamic>{},
        ),
      );
      
      if (officialTrailer.isNotEmpty && officialTrailer['key'] != null) {
        return officialTrailer['key'] as String;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}
