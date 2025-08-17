# Movie Review App

A Flutter application that allows users to browse and review movies using the TMDB (The Movie Database) API.

## Features

- **Top Rated Movies**: Display a horizontal list of top-rated movies
- **Movie Categories**: Browse movies by genre (Action, Comedy, Drama, Horror, Romance, etc.)
- **Movie Details**: View detailed information about each movie including:
  - Movie poster and backdrop images
  - Title and release date
  - Rating and user score
  - Overview/description
  - Genre information
- **Responsive Design**: Clean Material UI design that works on different screen sizes
- **Pull to Refresh**: Refresh movie data by pulling down on the screen
- **Error Handling**: Graceful error handling with retry functionality

## Technical Stack

- **Framework**: Flutter
- **State Management**: Provider
- **HTTP Client**: http package
- **Image Loading**: cached_network_image
- **UI Components**: Material Design 3
- **API**: TMDB (The Movie Database)

## Project Structure

```
lib/
├── models/
│   ├── movie.dart          # Movie data model
│   └── genre.dart          # Genre constants and model
├── services/
│   ├── movie_service.dart  # API service for TMDB
│   └── movie_provider.dart # State management with Provider
├── screens/
│   ├── home_screen.dart    # Main home screen
│   └── movie_detail_screen.dart # Movie detail screen
├── widgets/
│   ├── movie_card.dart     # Movie card for horizontal list
│   └── movie_grid_card.dart # Movie card for grid view
└── main.dart              # App entry point
```

## API Configuration

The app uses the TMDB API with the following configuration:
- **Base URL**: https://api.themoviedb.org/3
- **API Key**: e697e2f244416ee180c7971667767741
- **Image Base URL**: https://image.tmdb.org/t/p/w500

## Getting Started

### Prerequisites

- Flutter SDK (3.5.4 or higher)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd movie_review_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Usage

1. **Home Screen**: The app opens with a list of top-rated movies at the top
2. **Browse Categories**: Scroll down to see movie categories as filter chips
3. **Select Category**: Tap on any category to view movies of that genre
4. **View Movie Details**: Tap on any movie card to see detailed information
5. **Refresh**: Pull down on the screen to refresh the movie data

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0
  provider: ^6.1.1
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  go_router: ^12.1.3
```

## Features Implemented

✅ **Home Screen with Top Rated Movies**
- Horizontal scrolling list of top-rated movies
- Movie cards showing poster, title, and rating

✅ **Movie Categories**
- Filter chips for different genres
- Grid view of movies by selected category

✅ **Movie Detail Page**
- Large backdrop image with gradient overlay
- Movie poster and basic information
- Rating display with star icon
- Release date formatting
- Genre chips
- Movie overview/description

✅ **Clean Material UI Design**
- Material Design 3 components
- Responsive layout
- Consistent color scheme (Deep Purple theme)
- Loading states and error handling

✅ **State Management**
- Provider pattern for state management
- Proper separation of concerns
- Error handling and loading states

✅ **Code Organization**
- Organized into screens, widgets, services, and models folders
- Clean architecture principles
- Reusable components

## Screenshots

The app features:
- A beautiful home screen with top-rated movies
- Category filtering with filter chips
- Detailed movie information pages
- Responsive design for different screen sizes

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Acknowledgments

- [TMDB](https://www.themoviedb.org/) for providing the movie data API
- Flutter team for the amazing framework
- The open-source community for the packages used in this project
