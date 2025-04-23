# Time Tracker Pro

A professional time tracking application built with Flutter for freelancers and small businesses.

## Features

- ✅ Track time for different client projects
- ✅ Calculate earnings based on hourly rates
- ✅ View detailed reports and statistics
- ✅ Light/Dark theme support
- ✅ Export project data and invoices

## Screenshots

*Screenshots will be added once the application is finalized*

## Getting Started

### Prerequisites

- Flutter SDK (Latest stable version recommended)
- Dart SDK
- Visual Studio with Desktop development with C++ workload (for Windows)
- Xcode (for macOS and iOS)
- Android Studio (for Android)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/time_tracker_pro.git
cd time_tracker_pro
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the application
```bash
# For Windows
flutter run -d windows

# For macOS
flutter run -d macos

# For Web
flutter run -d chrome

# For Android
flutter run -d android

# For iOS
flutter run -d ios
```

## Troubleshooting

### Windows Build Issues

If you encounter a build error like `cannot open file` or permission issues:

1. Close any running instances of the app
2. Close Visual Studio if open
3. Try running as Administrator
4. Delete the build folder manually and rebuild:
```bash
# In PowerShell with admin rights
Remove-Item -Recurse -Force .\build\
flutter run -d windows
```

### Debug Mode

The app includes a built-in debug inspector that can help diagnose issues:

- **In debug mode**: Click the bug icon in the navigation rail
- **In release mode**: Tap the app logo 5 times in quick succession

The debug inspector allows you to:
- View diagnostics about Hive storage
- Reset theme settings
- Clear all app data

### Common Issues and Solutions

#### App crashes on startup

This is usually related to Hive database corruption. Try the following:

1. Clear app data:
   - Windows: Delete `%LOCALAPPDATA%\<package-name>\hive_storage`
   - Android: Clear app data in Settings
   - iOS: Reinstall the app

2. If using the Debug Inspector, use the "Clear All Data" option

#### Theme doesn't change

If toggling the theme doesn't work:

1. Use the Debug Inspector to reset theme settings
2. Make sure the settings box is open properly
3. Check if the theme provider is correctly initialized

#### UI doesn't update after data changes

This could be related to:
1. Provider state not updating correctly
2. Missing state notifier calls
3. UI not listening to state changes

Try restarting the app or clearing cached data.

### Icon Generation

To regenerate app icons from the logo:

```bash
flutter pub run flutter_launcher_icons
```

## Architecture

This application uses:

- **Riverpod** for state management
- **Hive** for local data persistence
- **PDF** for invoice generation
- **Material Design 3** for the UI

## File Structure

```
lib/
├── features/             # Feature modules
│   ├── dashboard/        # Dashboard feature
│   ├── projects/         # Projects management
│   ├── timer/            # Time tracking 
│   └── invoice/          # Invoice generation
├── theme/                # Theme configuration
├── widgets/              # Reusable widgets
├── tools/                # Utility scripts
└── main.dart             # Application entry point
```

## Customization

### Themes

The app supports both light and dark themes. The theme can be toggled using the switch in the dashboard.

### App Icons

The app icon is generated from the logo.png file in the assets directory. To change the icon:

1. Replace the `assets/logo.png` file with your own logo
2. Run the icon generation command:
```bash
flutter pub run flutter_launcher_icons
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter Team for the amazing framework
- All the open-source contributors for the packages used
