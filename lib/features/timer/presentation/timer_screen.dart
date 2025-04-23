import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/data/models/project.dart';
import '../../projects/data/providers.dart';
import '../../invoice/invoice_service.dart';
import '../../../widgets/custom_card.dart';
import '../../../utils/responsive_utils.dart';

class TimerScreen extends ConsumerStatefulWidget {
  final Project project;

  const TimerScreen({
    super.key,
    required this.project,
  });

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;
  late Project _currentProject;

  @override
  void initState() {
    super.initState();
    _currentProject = widget.project;
    debugPrint(
        '🕒 Timer screen initialized for project: ${_currentProject.clientName}');
  }

  @override
  void dispose() {
    _timer?.cancel();
    debugPrint('🛑 Timer screen disposed');
    super.dispose();
  }

  void _startTimer() {
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('What are you working on?'),
          content: TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (e.g., feature name)',
              hintText: 'Enter what you\'re working on',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final description = descriptionController.text.trim();
                final now = DateTime.now();

                // Start the timer with description
                ref.read(activeTimerProvider.notifier).startTimer(
                      now,
                      description: description.isNotEmpty ? description : null,
                    );

                debugPrint(
                    '▶️ Timer started at ${now.toIso8601String()} for "$description"');

                setState(() {
                  _isRunning = true;
                  _elapsed = Duration.zero;
                });

                _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                  setState(() {
                    _elapsed = Duration(seconds: timer.tick);
                  });
                });

                Navigator.of(context).pop();
              },
              child: const Text('Start Timer'),
            ),
          ],
        );
      },
    );
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;

    final now = DateTime.now();
    final timerController = ref.read(activeTimerProvider.notifier);
    timerController.stopTimer(now);
    debugPrint('⏹️ Timer stopped at ${now.toIso8601String()}');

    // Get the active timer
    final activeTimer = ref.read(activeTimerProvider);
    if (activeTimer != null && activeTimer.endTime != null) {
      try {
        // Use the ProjectsNotifier to add the time entry instead of TimerRepository directly
        ref
            .read(projectsProvider.notifier)
            .addTimeEntry(_currentProject.id, activeTimer);

        // No need to manually update _currentProject here as we're now watching projectsProvider
        // in the build method which will handle the UI update automatically

        debugPrint('✅ Time entry added successfully');

        // Show success message if the widget is still mounted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Time entry saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ Error adding time entry: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving time entry: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    setState(() {
      _isRunning = false;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = ResponsiveSizing.getScreenSize(context);

    // Listen for project updates
    final projects = ref.watch(projectsProvider);
    final updatedProject = projects.firstWhere(
      (p) => p.id == widget.project.id,
      orElse: () => widget.project,
    );

    // Update current project if it has changed
    if (updatedProject.id == _currentProject.id &&
        updatedProject.timeEntries.length !=
            _currentProject.timeEntries.length) {
      _currentProject = updatedProject;
      debugPrint(
          '🔄 Project updated: ${_currentProject.timeEntries.length} time entries');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentProject.clientName),
        elevation: 2,
      ),
      body: Padding(
        padding: ResponsiveSizing.getPadding(context),
        child: screenSize == ScreenSize.small
            ? _buildCompactLayout(theme)
            : _buildExpandedLayout(theme),
      ),
    );
  }

  // Compact layout for small screens
  Widget _buildCompactLayout(ThemeData theme) {
    return Column(
      children: [
        _buildTimerCard(theme),
        const SizedBox(height: 16),
        Expanded(
          child: _buildSessionHistory(theme),
        ),
      ],
    );
  }

  // Expanded layout for medium and large screens
  Widget _buildExpandedLayout(ThemeData theme) {
    return Column(
      children: [
        _buildTimerCard(theme),
        const SizedBox(height: 24),
        Expanded(
          child: _buildSessionHistory(theme),
        ),
      ],
    );
  }

  Widget _buildTimerCard(ThemeData theme) {
    // Get the current timer state to show description
    final activeTimer = ref.watch(activeTimerProvider);
    final currentDescription = activeTimer?.description;
    final screenSize = ResponsiveSizing.getScreenSize(context);

    return CustomCard(
      margin: EdgeInsets.all(screenSize == ScreenSize.small ? 8 : 16),
      padding: EdgeInsets.all(screenSize == ScreenSize.small ? 16 : 24),
      child: Column(
        children: [
          Text(
            'Current Session',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: ResponsiveSizing.getHeadingFontSize(context),
            ),
          ),
          if (currentDescription != null && currentDescription.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                currentDescription,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(height: screenSize == ScreenSize.small ? 16 : 32),
          Text(
            _formatDuration(_elapsed),
            style: TextStyle(
              fontSize: screenSize == ScreenSize.small ? 36 : 48,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: screenSize == ScreenSize.small ? 16 : 32),
          // Make the rate and earnings display responsive
          screenSize == ScreenSize.small
              ? Column(
                  children: [
                    Text(
                      'Rate: \$${_currentProject.hourlyRate.toStringAsFixed(2)}/hr',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Earning: \$${(_elapsed.inSeconds / 3600 * _currentProject.hourlyRate).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Rate: \$${_currentProject.hourlyRate.toStringAsFixed(2)}/hr',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Earning: \$${(_elapsed.inSeconds / 3600 * _currentProject.hourlyRate).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
          SizedBox(height: screenSize == ScreenSize.small ? 16 : 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRunning)
                ElevatedButton.icon(
                  onPressed: _startTimer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Timer'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize == ScreenSize.small ? 16 : 32,
                      vertical: 12,
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _stopTimer,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Timer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize == ScreenSize.small ? 16 : 32,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionHistory(ThemeData theme) {
    final screenSize = ResponsiveSizing.getScreenSize(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize == ScreenSize.small ? 8.0 : 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Session History',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: ResponsiveSizing.getHeadingFontSize(context),
                ),
              ),
              if (_currentProject.timeEntries.isNotEmpty)
                TextButton.icon(
                  onPressed: () async {
                    await _exportSessions(context);
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: screenSize == ScreenSize.small
                      ? const SizedBox.shrink()
                      : const Text('Export All'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _currentProject.timeEntries.isEmpty
              ? Center(
                  child: Text(
                    'No sessions recorded yet',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  padding:
                      EdgeInsets.all(screenSize == ScreenSize.small ? 8 : 16),
                  itemCount: _currentProject.timeEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _currentProject.timeEntries[index];
                    final isComplete = entry.endTime != null;
                    final duration = isComplete
                        ? entry.endTime!.difference(entry.startTime)
                        : const Duration(seconds: 0);
                    final hours = duration.inMinutes / 60;
                    final earnings = hours * _currentProject.hourlyRate;

                    return CustomCard(
                      margin: EdgeInsets.only(
                        bottom: screenSize == ScreenSize.small ? 4 : 8,
                      ),
                      child: ListTile(
                        dense: screenSize == ScreenSize.small,
                        leading: CircleAvatar(
                          radius: screenSize == ScreenSize.small ? 16 : 20,
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.timer,
                            color: theme.colorScheme.primary,
                            size: screenSize == ScreenSize.small ? 16 : 20,
                          ),
                        ),
                        title: Text(
                          '${entry.startTime.day}/${entry.startTime.month}/${entry.startTime.year} - ${_formatDuration(duration)}',
                          style: TextStyle(
                            fontSize: screenSize == ScreenSize.small ? 12 : 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Earned: \$${earnings.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize:
                                    screenSize == ScreenSize.small ? 11 : 13,
                              ),
                            ),
                            if (entry.description != null &&
                                entry.description!.isNotEmpty)
                              Text(
                                'Task: ${entry.description}',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: theme.colorScheme.secondary,
                                  fontSize:
                                      screenSize == ScreenSize.small ? 10 : 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${hours.toStringAsFixed(1)} hrs',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize:
                                    screenSize == ScreenSize.small ? 11 : 13,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                size: screenSize == ScreenSize.small ? 16 : 20,
                              ),
                              onSelected: (value) async {
                                switch (value) {
                                  case 'edit':
                                    await _editTimeEntry(context, index, entry);
                                    break;
                                  case 'delete':
                                    await _deleteTimeEntry(context, index);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit,
                                          size: screenSize == ScreenSize.small
                                              ? 16
                                              : 18),
                                      const SizedBox(width: 8),
                                      const Text('Edit Entry'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: screenSize == ScreenSize.small
                                            ? 16
                                            : 18,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Delete Entry',
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Edit time entry
  Future<void> _editTimeEntry(
      BuildContext context, int index, TimeEntry entry) async {
    try {
      final descriptionController =
          TextEditingController(text: entry.description ?? '');

      // Show a dialog to edit the description first
      final dialogResult = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Edit Task Description'),
            content: TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What were you working on?',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false); // Cancel
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true); // Continue
                },
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );

      // Check if dialog was dismissed or canceled
      if (dialogResult != true || !mounted) return;

      // Continue with start time selection
      DateTime? startTime;
      await _showDateTimePicker(
        context: context,
        isStartTime: true,
        initialDateTime: entry.startTime,
        onSelected: (selected) {
          startTime = selected;
        },
      );

      // Check if start time was selected
      if (startTime == null || !mounted) return;

      // Only proceed with end time if we have one
      if (entry.endTime != null) {
        DateTime? endTime;
        await _showDateTimePicker(
          context: context,
          isStartTime: false,
          initialDateTime: entry.endTime!,
          onSelected: (selected) {
            endTime = selected;
          },
        );

        // Check if end time was selected
        if (endTime == null || !mounted) return;

        // Check if end time is valid
        if (endTime!.isBefore(startTime!)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('End time cannot be before start time'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Update the time entry
        try {
          final description = descriptionController.text.trim();

          final updatedEntry = TimeEntry(
            startTime: startTime!,
            endTime: endTime,
            description: description.isNotEmpty ? description : null,
          );

          // Use the ProjectsNotifier to update the time entry
          ref
              .read(projectsProvider.notifier)
              .updateTimeEntry(_currentProject.id, index, updatedEntry);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Time entry updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          debugPrint('❌ Error updating time entry: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating time entry: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error in edit time entry flow: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Delete time entry
  Future<void> _deleteTimeEntry(BuildContext context, int index) async {
    try {
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Delete Time Entry'),
            content: const Text(
                'Are you sure you want to delete this time entry? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      // Check if dialog was dismissed or canceled
      if (shouldDelete != true || !mounted) return;

      try {
        // Use the ProjectsNotifier to delete the time entry
        ref
            .read(projectsProvider.notifier)
            .deleteTimeEntry(_currentProject.id, index);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Time entry deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ Error deleting time entry: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting time entry: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error in delete time entry flow: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Export all sessions
  Future<void> _exportSessions(BuildContext context) async {
    try {
      // Show a loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generating session report...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Generate and export the session report
      try {
        await InvoiceService.generateSessionReport(_currentProject);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session report generated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (error) {
        debugPrint('❌ Error generating report: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error generating report: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error preparing session report: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error preparing report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper for date time picker
  Future<void> _showDateTimePicker({
    required BuildContext context,
    required bool isStartTime,
    required DateTime initialDateTime,
    required Function(DateTime) onSelected,
  }) async {
    // Create a separate method-level navigator key
    final navigatorKey = GlobalKey<NavigatorState>();

    try {
      // Show date picker and await result
      final selectedDate = await showDatePicker(
        context: context,
        initialDate: initialDateTime,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 1)),
      );

      // If date was selected and widget still mounted
      if (selectedDate != null && mounted) {
        // Show time picker and await result
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initialDateTime),
        );

        // If time was selected and widget still mounted
        if (selectedTime != null && mounted) {
          final selectedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
          onSelected(selectedDateTime);
        }
      }
    } catch (e) {
      debugPrint('❌ Error selecting date/time: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting date/time: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
