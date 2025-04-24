import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:window_manager/window_manager.dart';
import 'features/projects/presentation/projects_screen.dart';
import 'features/projects/data/models/project.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'widgets/splash_screen.dart';
import 'widgets/logo_widget.dart';
import 'widgets/about_dialog.dart' as about;
import 'theme/theme_provider.dart';
import 'tools/debug_inspector.dart';

// Set up global error handling
void setupErrorHandling() {
  // Override Flutter's error widget in debug mode
  if (kDebugMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flutter Error',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              details.exception.toString(),
              style: TextStyle(color: Colors.red.shade900),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: SingleChildScrollView(
                child: Text(
                  details.stack.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    };
  }

  // Set up Flutter error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('❌ Flutter Error: ${details.exception}');
    debugPrint(details.stack.toString());
  };

  // Set up Dart error handling
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('❌ Dart Error: $error');
    debugPrint(stack.toString());
    return true;
  };
}

// Configure window size for desktop platforms
Future<void> configureWindowSize() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize window manager
    await windowManager.ensureInitialized();

    // Set window title
    windowManager.setTitle('Time Tracker Pro');

    // WindowOptions for desktop
    final windowOptions = WindowOptions(
      size: const Size(1280, 800), // Initial size
      minimumSize: const Size(760, 640), // Minimum size
      center: true, // Center window on screen
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    // Apply window options
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      // Show the window
      await windowManager.show();
      // Prevent window from being resized too large
      await windowManager.setMaximumSize(const Size(1600, 1000));
    });
  }
}

// Register Hive adapters to ensure proper data serialization
void registerHiveAdapters() {
  try {
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(TimeEntryAdapter());
    debugPrint('✅ Hive adapters registered successfully');
  } catch (e) {
    debugPrint('❌ Error registering Hive adapters: $e');
    throw Exception('Failed to register Hive adapters: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupErrorHandling();

  // Configure window size
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await configureWindowSize();
  }

  try {
    // 1. Use Application Support Directory (Windows: AppData/Local)
    final appDir = await getApplicationSupportDirectory();

    // 2. Create platform-appropriate path
    final hivePath = path.join(appDir.path, 'hive_storage');

    debugPrint('📂 Hive Storage Path: $hivePath');

    // 3. Ensure directory exists
    final dir = Directory(hivePath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      debugPrint('📁 Created Hive storage directory');
    }

    // 4. Initialize Hive with verified path
    await Hive.initFlutter(hivePath);
    debugPrint('🚀 Hive initialized successfully');

    // 5. Register Hive adapters
    registerHiveAdapters();

    // 6. Open Hive boxes
    if (!Hive.isBoxOpen('projects')) {
      await Hive.openBox<Project>('projects');
      debugPrint('📦 Opened projects box successfully');
    } else {
      debugPrint('ℹ️ Projects box is already open');
    }

    // Open settings box for theme
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
      debugPrint('📦 Opened settings box successfully');
    }

    runApp(
      const ProviderScope(
        child: WindowsApp(),
      ),
    );
  } catch (e) {
    debugPrint('❌ Hive Initialization Error: $e');
    runApp(ErrorApp(errorMessage: e.toString()));
  }
}

class WindowsApp extends ConsumerStatefulWidget {
  const WindowsApp({super.key});

  @override
  ConsumerState<WindowsApp> createState() => _WindowsAppState();
}

class _WindowsAppState extends ConsumerState<WindowsApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Show splash screen for 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the theme mode with safe fallback
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Time Tracker Pro',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      home: Builder(
        builder: (context) {
          try {
            return _showSplash ? const SplashScreen() : const AppShell();
          } catch (e, stackTrace) {
            debugPrint('❌ Error in WindowsApp: $e');
            debugPrint(stackTrace.toString());

            // Fallback to a simple error screen
            return Scaffold(
              backgroundColor: Colors.red.shade100,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Application Error',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.toString(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showSplash = true;
                          });
                          Timer(const Duration(seconds: 1), () {
                            if (mounted) {
                              setState(() {
                                _showSplash = false;
                              });
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Restart App'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  int _debugTapCount = 0;
  Timer? _debugResetTimer;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProjectsScreen(),
  ];

  void _handleLogoTap() {
    // Navigate to dashboard when logo is tapped
    setState(() {
      _selectedIndex = 0;
    });

    // Increment debug tap count
    _debugTapCount++;

    // Reset debug tap count after 3 seconds of inactivity
    _debugResetTimer?.cancel();
    _debugResetTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _debugTapCount = 0;
        });
      }
    });

    // Launch debug inspector after 5 rapid taps
    if (_debugTapCount >= 5) {
      _debugTapCount = 0;
      _debugResetTimer?.cancel();

      launchDebugInspector(context);
    }
  }

  @override
  void dispose() {
    _debugResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Make sure we have a valid context and Theme
    if (!mounted) return const SizedBox.shrink();

    Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: false,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              if (index < 0 || index >= _screens.length) return;
              setState(() {
                _selectedIndex = index;
              });
            },
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: LogoWidget(
                size: 40,
                onTap: _handleLogoTap,
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.folder),
                label: Text('Projects'),
              ),
            ],
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      about.showAboutDialog(context);
                    },
                    tooltip: 'About',
                  ),
                  if (kDebugMode)
                    IconButton(
                      icon: const Icon(Icons.bug_report),
                      onPressed: () {
                        launchDebugInspector(context);
                      },
                      tooltip: 'Debug',
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _selectedIndex < _screens.length
                ? _screens[_selectedIndex]
                : const Center(child: Text('Screen not found')),
          ),
        ],
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String errorMessage;

  const ErrorApp({super.key, this.errorMessage = 'Unknown error'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red[700],
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  'Failed to initialize application',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Restart app
                    main();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
