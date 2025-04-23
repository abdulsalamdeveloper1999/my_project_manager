import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A debug tool that can be used to inspect the app's state and fix issues
class DebugInspector extends StatefulWidget {
  const DebugInspector({super.key});

  @override
  State<DebugInspector> createState() => _DebugInspectorState();
}

class _DebugInspectorState extends State<DebugInspector> {
  final List<String> _logs = [];
  final Map<String, dynamic> _diagnostics = {};

  @override
  void initState() {
    super.initState();
    _collectDiagnostics();
  }

  Future<void> _collectDiagnostics() async {
    setState(() {
      _logs.add('📊 Starting diagnostics...');
    });

    try {
      // Check Hive boxes
      final boxesInfo = <String, dynamic>{};

      // Get list of box names from Hive
      final boxNames = ['projects', 'settings'];

      for (final boxName in boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            final count = box.length;

            boxesInfo[boxName] = {
              'length': count,
              'isOpen': true,
            };

            setState(() {
              _logs.add('📦 Box $boxName: $count items');
            });
          } else {
            boxesInfo[boxName] = {
              'isOpen': false,
              'error': 'Box is not open',
            };

            setState(() {
              _logs.add('⚠️ Box $boxName is not open');
            });
          }
        } catch (e) {
          boxesInfo[boxName] = {'error': e.toString()};
          setState(() {
            _logs.add('❌ Error inspecting box $boxName: $e');
          });
        }
      }

      _diagnostics['hiveBoxes'] = boxesInfo;

      // Check theme settings
      try {
        if (Hive.isBoxOpen('settings')) {
          final settingsBox = Hive.box('settings');
          final isDarkMode = settingsBox.get('isDarkMode', defaultValue: false);

          _diagnostics['themeSettings'] = {
            'isDarkMode': isDarkMode,
          };

          setState(() {
            _logs.add('🎨 Theme mode: ${isDarkMode ? 'Dark' : 'Light'}');
          });
        } else {
          _diagnostics['themeSettings'] = {'error': 'Settings box is not open'};
          setState(() {
            _logs.add('⚠️ Theme settings box is not open');
          });
        }
      } catch (e) {
        _diagnostics['themeSettings'] = {'error': e.toString()};
        setState(() {
          _logs.add('❌ Error checking theme settings: $e');
        });
      }

      setState(() {
        _logs.add('✅ Diagnostics completed');
      });
    } catch (e) {
      setState(() {
        _logs.add('❌ Error in diagnostics: $e');
      });
    }
  }

  Future<void> _resetThemeSettings() async {
    try {
      if (Hive.isBoxOpen('settings')) {
        final settingsBox = Hive.box('settings');
        await settingsBox.put('isDarkMode', false);

        setState(() {
          _logs.add('✅ Reset theme to Light mode');
        });
      } else {
        setState(() {
          _logs.add('⚠️ Cannot reset theme: Settings box is not open');
        });
      }

      await _collectDiagnostics();
    } catch (e) {
      setState(() {
        _logs.add('❌ Error resetting theme: $e');
      });
    }
  }

  Future<void> _clearAllData() async {
    try {
      final boxNames = ['projects', 'settings'];

      for (final boxName in boxNames) {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          await box.clear();
          setState(() {
            _logs.add('🧹 Cleared box: $boxName');
          });
        } else {
          setState(() {
            _logs.add('⚠️ Box $boxName is not open, cannot clear');
          });
        }
      }

      setState(() {
        _logs.add('✅ All data cleared');
      });

      await _collectDiagnostics();
    } catch (e) {
      setState(() {
        _logs.add('❌ Error clearing data: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Inspector'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _collectDiagnostics,
            tooltip: 'Refresh Diagnostics',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[_logs.length - 1 - index]; // Reverse order
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Text(log),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _resetThemeSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Reset Theme'),
                ),
                ElevatedButton(
                  onPressed: _clearAllData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Clear All Data'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Launch the debug inspector (only in debug mode)
void launchDebugInspector(BuildContext context) {
  if (kDebugMode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DebugInspector(),
      ),
    );
  }
}
