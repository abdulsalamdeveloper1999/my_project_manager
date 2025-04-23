import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/data/providers.dart';
import '../../projects/data/models/project.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/theme_switch.dart';
import '../../../utils/responsive_utils.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final theme = Theme.of(context);
    final screenSize = ResponsiveSizing.getScreenSize(context);
    final padding = ResponsiveSizing.getPadding(context);

    // Calculate statistics
    final stats = _calculateStatistics(projects);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Text(
                  'Theme',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                const ThemeSwitch(),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards - use Wrap for better responsiveness on small windows
            _buildSummaryCards(context, stats, theme, screenSize),
            SizedBox(height: screenSize == ScreenSize.small ? 16 : 24),

            // Recent activity
            Text(
              'Recent Activity',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: ResponsiveSizing.getHeadingFontSize(context),
              ),
            ),
            const SizedBox(height: 8),
            _buildRecentActivityList(context, projects),

            SizedBox(height: screenSize == ScreenSize.small ? 16 : 24),

            // Earnings chart
            Text(
              'Earnings by Project',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: ResponsiveSizing.getHeadingFontSize(context),
              ),
            ),
            const SizedBox(height: 8),
            _buildEarningsChart(context, projects),

            SizedBox(height: screenSize == ScreenSize.small ? 16 : 24),

            // Calendar heatmap for last 30 days
            Text(
              'Activity in the Last 30 Days',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: ResponsiveSizing.getHeadingFontSize(context),
              ),
            ),
            const SizedBox(height: 8),
            _buildActivityHeatmap(context, projects),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, DashboardStats stats,
      ThemeData theme, ScreenSize screenSize) {
    // Use different layouts based on screen size
    switch (screenSize) {
      case ScreenSize.small:
        // Stack cards vertically on small screens
        return Column(
          children: [
            _buildStatCard(
              context,
              Icons.folder_outlined,
              'Active Projects',
              '${stats.activeProjects}',
              theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            _buildStatCard(
              context,
              Icons.timer_outlined,
              'Total Hours',
              stats.totalHours.toStringAsFixed(1),
              theme.colorScheme.secondary,
            ),
            const SizedBox(height: 8),
            _buildStatCard(
              context,
              Icons.attach_money_outlined,
              'Total Earnings',
              '\$${stats.totalEarnings.toStringAsFixed(2)}',
              theme.colorScheme.tertiary,
            ),
          ],
        );

      case ScreenSize.medium:
        // Two cards per row on medium screens
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.folder_outlined,
                    'Active Projects',
                    '${stats.activeProjects}',
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.timer_outlined,
                    'Total Hours',
                    stats.totalHours.toStringAsFixed(1),
                    theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              context,
              Icons.attach_money_outlined,
              'Total Earnings',
              '\$${stats.totalEarnings.toStringAsFixed(2)}',
              theme.colorScheme.tertiary,
            ),
          ],
        );

      case ScreenSize.large:
      default:
        // Three cards in a row on large screens
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                Icons.folder_outlined,
                'Active Projects',
                '${stats.activeProjects}',
                theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                Icons.timer_outlined,
                'Total Hours',
                stats.totalHours.toStringAsFixed(1),
                theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                Icons.attach_money_outlined,
                'Total Earnings',
                '\$${stats.totalEarnings.toStringAsFixed(2)}',
                theme.colorScheme.tertiary,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String title,
      String value, Color color) {
    // Make height responsive to screen size
    final height = ResponsiveSizing.getCardHeight(context);

    return CustomCard(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(
      BuildContext context, List<Project> projects) {
    // Collect all time entries from all projects
    final allEntries = <TimeEntryWithProject>[];

    for (final project in projects) {
      for (final entry in project.timeEntries) {
        if (entry.endTime != null) {
          allEntries.add(
            TimeEntryWithProject(
              project: project,
              entry: entry,
            ),
          );
        }
      }
    }

    // Sort by most recent first
    allEntries.sort((a, b) => b.entry.startTime.compareTo(a.entry.startTime));

    // Take only the most recent 5 entries
    final recentEntries = allEntries.take(5).toList();

    if (recentEntries.isEmpty) {
      return CustomCard(
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No recent activity found'),
          ),
        ),
      );
    }

    return CustomCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentEntries.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = recentEntries[index];
          final duration = item.entry.endTime!.difference(item.entry.startTime);
          final hours = duration.inMinutes / 60;
          final earnings = hours * item.project.hourlyRate;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.timer,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(item.project.clientName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatDate(item.entry.startTime)} (${_formatDuration(duration)})',
                ),
                if (item.entry.description != null &&
                    item.entry.description!.isNotEmpty)
                  Text(
                    item.entry.description!,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: Text(
              '\$${earnings.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEarningsChart(BuildContext context, List<Project> projects) {
    // Calculate earnings per project
    final projectEarnings = <ProjectEarnings>[];

    for (final project in projects) {
      double totalEarnings = 0;

      for (final entry in project.timeEntries) {
        if (entry.endTime != null) {
          final duration = entry.endTime!.difference(entry.startTime);
          final hours = duration.inMinutes / 60;
          totalEarnings += hours * project.hourlyRate;
        }
      }

      if (totalEarnings > 0) {
        projectEarnings.add(
          ProjectEarnings(
            project: project,
            earnings: totalEarnings,
          ),
        );
      }
    }

    // Sort by earnings (highest first)
    projectEarnings.sort((a, b) => b.earnings.compareTo(a.earnings));

    if (projectEarnings.isEmpty) {
      return CustomCard(
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No earnings data available'),
          ),
        ),
      );
    }

    // Get total earnings for percentage calculation
    final totalEarnings =
        projectEarnings.fold<double>(0, (sum, item) => sum + item.earnings);

    return CustomCard(
      child: Column(
        children: [
          ...projectEarnings.map((item) {
            final percentage = totalEarnings > 0
                ? (item.earnings / totalEarnings * 100).toStringAsFixed(1)
                : '0';

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.project.clientName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: totalEarnings > 0
                                  ? item.earnings / totalEarnings
                                  : 0,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: Text(
                        '\$${item.earnings.toStringAsFixed(2)} ($percentage%)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivityHeatmap(BuildContext context, List<Project> projects) {
    // Get the last 30 days
    final now = DateTime.now();
    final days = List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      return DateTime(date.year, date.month, date.day);
    });

    // Count time entries per day
    final activityMap = <DateTime, int>{};

    for (final day in days) {
      activityMap[day] = 0;
    }

    for (final project in projects) {
      for (final entry in project.timeEntries) {
        final date = DateTime(
          entry.startTime.year,
          entry.startTime.month,
          entry.startTime.day,
        );

        if (activityMap.containsKey(date)) {
          activityMap[date] = (activityMap[date] ?? 0) + 1;
        }
      }
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Less', style: Theme.of(context).textTheme.bodySmall),
              Text('More', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade300,
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  Theme.of(context).colorScheme.primary,
                ],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 days per week
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final day = days[index];
              final count = activityMap[day] ?? 0;

              // Calculate color intensity based on count
              final intensity = count == 0
                  ? 0.0
                  : count < 2
                      ? 0.3
                      : count < 4
                          ? 0.6
                          : 1.0;

              return Tooltip(
                message: '${_formatDate(day)}: $count activities',
                child: Container(
                  decoration: BoxDecoration(
                    color: count == 0
                        ? Colors.grey.shade300
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(intensity),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        color: intensity > 0.6 ? Colors.white : Colors.black,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  DashboardStats _calculateStatistics(List<Project> projects) {
    int activeProjects = 0;
    double totalHours = 0;
    double totalEarnings = 0;

    for (final project in projects) {
      bool hasRecentActivity = false;
      double projectHours = 0;

      for (final entry in project.timeEntries) {
        if (entry.endTime != null) {
          final duration = entry.endTime!.difference(entry.startTime);
          final hours = duration.inMinutes / 60;
          projectHours += hours;

          // Check if there's activity in the last 30 days
          final now = DateTime.now();
          final thirtyDaysAgo = now.subtract(const Duration(days: 30));
          if (entry.startTime.isAfter(thirtyDaysAgo)) {
            hasRecentActivity = true;
          }
        }
      }

      if (hasRecentActivity || project.timeEntries.isEmpty) {
        activeProjects++;
      }

      totalHours += projectHours;
      totalEarnings += projectHours * project.hourlyRate;
    }

    return DashboardStats(
      activeProjects: activeProjects,
      totalHours: totalHours,
      totalEarnings: totalEarnings,
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }
}

// Helper classes
class DashboardStats {
  final int activeProjects;
  final double totalHours;
  final double totalEarnings;

  DashboardStats({
    required this.activeProjects,
    required this.totalHours,
    required this.totalEarnings,
  });
}

class TimeEntryWithProject {
  final Project project;
  final TimeEntry entry;

  TimeEntryWithProject({
    required this.project,
    required this.entry,
  });
}

class ProjectEarnings {
  final Project project;
  final double earnings;

  ProjectEarnings({
    required this.project,
    required this.earnings,
  });
}
