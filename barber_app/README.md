# Barber App

## Overview
The Barber App is a Flutter application designed to provide users with a seamless experience for booking appointments with barbers. The app features a user-friendly interface that allows users to log in, view available barbers, and schedule appointments.

## Features
- User authentication
- Login screen with input fields
- Home screen displaying available barbers
- Booking screen for scheduling appointments
- Reusable widgets for buttons and input fields

## Project Structure
```
barber_app
├── lib
│   ├── main.dart
│   ├── screens
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   └── booking_screen.dart
│   ├── widgets
│   │   ├── custom_button.dart
│   │   └── custom_input.dart
│   ├── models
│   │   ├── user.dart
│   │   └── appointment.dart
│   ├── services
│   │   └── auth_service.dart
│   └── utils
│       ├── constants.dart
│       └── theme.dart
├── pubspec.yaml
└── README.md
```

## Setup Instructions
1. Clone the repository:
   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```
   cd barber_app
   ```
3. Install the dependencies:
   ```
   flutter pub get
   ```
4. Run the app:
   ```
   flutter run
   ```

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.