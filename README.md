# Flutter YouTube Subscription App

## Overview

This Flutter application allows users to sign in with their Google accounts and subscribe to YouTube channels directly within the app.

## Features

- Google Sign-In for authentication
- Subscribe to YouTube channels
- Check if the user is already subscribed to a channel
- User-friendly notifications and error handling

## Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK
- Dart SDK
- A code editor (e.g., Visual Studio Code, Android Studio)
- An active Google account

## Setup

### 1. Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name

2. Install Dependencies
Navigate to your project directory and run:
flutter pub get

3. Create a Google Cloud Project
Go to the Google Cloud Console.
    1.Create a new project.
    2.Enable the YouTube Data API v3 for your project.
    3.Enable the Google People API.
4. Configure OAuth Consent Screen
    In the Google Cloud Console, navigate to "APIs & Services > OAuth consent screen."
    Fill out the necessary information and save.
important don't forget to give appropriet permission scopes.
5. Create OAuth 2.0 Credentials
    Go to "APIs & Services > Credentials."
    Click on "Create Credentials" and select "OAuth client ID."
    Choose "Application type"  or "Android" depending on your target.
6. Update Your Flutter App
In your Flutter app, add the following dependencies in pubspec.yaml:
    dependencies:
    flutter:
        sdk: flutter
    google_sign_in: ^5.0.0
    googleapis: ^4.0.0
    googleapis_auth: ^1.0.0
7. Implement Google Sign-In and YouTube Subscription Logic
Update your Flutter app with the following logic:

Google Sign-In: Use the google_sign_in package to authenticate users.
YouTube Subscription: Use the googleapis package to interact with the YouTube Data API.
Here is a brief example of how to implement these features:

****************************************************************
Contributing
If you'd like to contribute to this project, please follow these steps:

        Fork the project.
        Create a new branch (git checkout -b feature/YourFeature).
        Make your changes.
        Commit your changes (git commit -m 'Add some feature').
        Push to the branch (git push origin feature/YourFeature).
        Open a Pull Request.



```
