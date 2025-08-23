# GEMINI.md

## Project Overview

This project is a Flutter-based mobile application called "Frosty", a third-party client for the streaming platform Twitch. It aims to provide a better user experience by integrating with popular third-party services like BetterTTV (BTTV), FrankerFaceZ (FFZ), and 7TV, which are not supported by the official Twitch app.

The application is built using the Flutter framework and the Dart programming language. It uses Firebase for analytics and crash reporting, and MobX for state management. The app is available for both Android and iOS.

## Building and Running

To build and run the project, you will need to have Flutter installed.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/tommyxchow/frosty.git
    ```
2.  **Set up Twitch API credentials:**
    *   Go to the [Twitch dev console](https://dev.twitch.tv/login) and register a new application to retrieve a **Client ID** and **Client Secret**.
    *   Use `--dart-define` to set the `clientId` and `secret` environment variables with your **Client ID** and **Client Secret**.
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

## Development Conventions

*   **State Management:** The project uses MobX for state management. Code generation is required for MobX stores.
*   **Code Style:** The project uses the `flutter_lints` package to enforce good coding practices.
*   **Dependencies:** Dependencies are managed using the `pubspec.yaml` file.
*   **Firebase:** The project uses Firebase for analytics and crash reporting. A `firebase_options.dart` file is used to configure the Firebase integration.
*   **API Integration:** The application interacts with the Twitch API and other third-party APIs (BTTV, FFZ, 7TV) to fetch data.
