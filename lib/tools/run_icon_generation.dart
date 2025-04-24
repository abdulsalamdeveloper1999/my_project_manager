
/// This script provides instructions for running the icon generation.
/// Run this with:
/// flutter pub run flutter_launcher_icons
void main() {
  print('====== Run these commands to generate icons =====');
  print(
      '\n1. Run the following command in your terminal to generate icons for all platforms:');
  print('   flutter pub run flutter_launcher_icons');

  print('\n2. This will generate:');
  print('   - Android: icons in android/app/src/main/res/ directories');
  print('   - iOS: icons in ios/Runner/Assets.xcassets/AppIcon.appiconset/');
  print('   - Web: icons in web/icons/ and favicon.png');
  print('   - Windows: icon in windows/runner/resources/app_icon.ico');

  print('\n3. Verify that all icons have been generated');
  print('\n4. Build your app for each platform:');
  print('   - flutter build windows');
  print('   - flutter build web');
  print('   - flutter build apk');
  print('   - flutter build ios');

  print('\nNOTE: If you encounter any issues with icon generation:');
  print(
      '1. Make sure your logo.png is a high-quality square image (at least 1024x1024 pixels)');
  print(
      '2. Verify that the path in pubspec.yaml points to the correct location of logo.png');
  print('3. Try running the commands manually:');
  print('   - flutter clean');
  print('   - flutter pub get');
  print('   - flutter pub run flutter_launcher_icons');
}
