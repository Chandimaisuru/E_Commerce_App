class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
    );
  }

  String get fullPosterPath => 'https://image.tmdb.org/t/p/w500$posterPath';
  String get fullBackdropPath => 'https://image.tmdb.org/t/p/w500$backdropPath';
  
  // Extract year from release date
  String get releaseYear {
    if (releaseDate.isEmpty) return '';
    try {
      return releaseDate.split('-')[0];
    } catch (e) {
      return '';
    }
  }
  
  // Get title with year
  String get titleWithYear {
    if (releaseYear.isEmpty) return title;
    return '$title ($releaseYear)';
  }
}
