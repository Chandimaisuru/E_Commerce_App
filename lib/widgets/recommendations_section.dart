import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecommendationsSection extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;
  final bool isLoading;
  final Function(int) onMovieTap;

  const RecommendationsSection({
    super.key,
    required this.recommendations,
    required this.isLoading,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You May Also Like',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFD700),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        width: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'You May Also Like',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final movie = recommendations[index];
              final title = movie['title'] ?? 'Unknown';
              final posterPath = movie['poster_path'];
              final voteAverage = (movie['vote_average'] ?? 0.0).toDouble();
              final movieId = movie['id'] ?? 0;
              
              // Calculate match percentage based on vote average
              final matchPercentage = _calculateMatchPercentage(voteAverage);

              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Movie Poster with Match Badge
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () => onMovieTap(movieId),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: posterPath != null
                                  ? CachedNetworkImage(
                                      imageUrl: 'https://image.tmdb.org/t/p/w185$posterPath',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: const Color(0xFF2C2C2C),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xFFFFD700),
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: const Color(0xFF2C2C2C),
                                        child: const Icon(
                                          Icons.movie,
                                          color: Colors.grey,
                                          size: 40,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: const Color(0xFF2C2C2C),
                                      child: const Icon(
                                        Icons.movie,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        
                        // Match Percentage Badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getMatchColor(matchPercentage),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${matchPercentage}%',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Movie Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: Color(0xFFFFD700),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          voteAverage.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  int _calculateMatchPercentage(double voteAverage) {
    // Convert vote average (0-10) to percentage (0-100)
    // Most movies have vote averages between 5-8, so we'll scale accordingly
    if (voteAverage >= 8.0) return 95;
    if (voteAverage >= 7.5) return 90;
    if (voteAverage >= 7.0) return 85;
    if (voteAverage >= 6.5) return 80;
    if (voteAverage >= 6.0) return 75;
    if (voteAverage >= 5.5) return 70;
    if (voteAverage >= 5.0) return 65;
    if (voteAverage >= 4.5) return 60;
    if (voteAverage >= 4.0) return 55;
    return 50;
  }

  Color _getMatchColor(int percentage) {
    if (percentage >= 70) return Colors.green; // Green for 70% and above
    if (percentage >= 40) return Colors.orange; // Orange for 40-69%
    return Colors.red; // Red for below 40%
  }
}
