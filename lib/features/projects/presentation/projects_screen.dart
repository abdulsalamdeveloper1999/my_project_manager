import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';
import '../data/models/project.dart';
import '../../timer/presentation/timer_screen.dart';
import 'package:uuid/uuid.dart';
import '../../invoice/invoice_service.dart';
import '../../../widgets/custom_card.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the projects list using the state notifier provider
    final projects = ref.watch(projectsProvider);
    debugPrint('🧩 Building ProjectsScreen with ${projects.length} projects');

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: projects.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return ProjectCard(
                    project: project,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimerScreen(project: project),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProjectDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.work_outline,
            size: 70,
            color: Color(0xFF2A5CAC),
          ),
          const SizedBox(height: 16),
          Text(
            'No projects yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first project',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context, WidgetRef ref) {
    final clientNameController = TextEditingController();
    final hourlyRateController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Project'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: clientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Client Name',
                    icon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a client name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: hourlyRateController,
                  decoration: const InputDecoration(
                    labelText: 'Hourly Rate (\$)',
                    icon: Icon(Icons.attach_money),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an hourly rate';
                    }
                    try {
                      final rate = double.parse(value);
                      if (rate <= 0) {
                        return 'Rate must be greater than zero';
                      }
                    } catch (e) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
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
                if (formKey.currentState?.validate() ?? false) {
                  try {
                    final uuid = const Uuid();
                    final projectId = uuid.v4();
                    debugPrint('🆕 Creating new project with ID: $projectId');

                    final project = Project(
                      id: projectId,
                      clientName: clientNameController.text.trim(),
                      hourlyRate: double.parse(hourlyRateController.text),
                      timeEntries: [],
                    );

                    // Use the state notifier to add the project
                    ref.read(projectsProvider.notifier).addProject(project);
                    debugPrint(
                        '✅ Project added successfully: ${project.clientName}');

                    Navigator.of(context).pop();
                  } catch (e) {
                    debugPrint('❌ Error adding project: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding project: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class ProjectCard extends ConsumerWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Calculate total hours for the project
    double totalHours = 0;
    for (final entry in project.timeEntries) {
      if (entry.endTime != null) {
        final duration = entry.endTime!.difference(entry.startTime);
        totalHours += duration.inSeconds / 3600.0; // Convert seconds to hours
      }
    }

    // Calculate total earnings
    final totalEarnings = totalHours * project.hourlyRate;

    // Debug print statements to trace values
    debugPrint('Project: ${project.clientName}');
    debugPrint('Total Hours: $totalHours');
    debugPrint('Hourly Rate: ${project.hourlyRate}');
    debugPrint('Total Earnings: $totalEarnings');

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.clientName,
                  style: theme.textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '\$${project.hourlyRate.toStringAsFixed(2)}/hr',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editProject(context, ref, project);
                          break;
                        case 'delete':
                          _deleteProject(context, ref, project);
                          break;
                        case 'export':
                          _exportInvoice(context, project);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Project'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Project',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf, size: 18),
                            SizedBox(width: 8),
                            Text('Export Invoice'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                context,
                Icons.timer_outlined,
                '${totalHours.toStringAsFixed(1)} hrs',
              ),
              _buildInfoItem(
                context,
                Icons.calendar_today_outlined,
                '${project.timeEntries.length} sessions',
              ),
              _buildInfoItem(
                context,
                Icons.account_balance_wallet_outlined,
                '\$${totalEarnings.toStringAsFixed(2)}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: project.timeEntries.isEmpty
                ? 0
                : 0.7, // Update with real progress when available
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.secondary, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

// Edit project dialog
  void _editProject(BuildContext context, WidgetRef ref, Project project) {
    final clientNameController =
        TextEditingController(text: project.clientName);
    final hourlyRateController =
        TextEditingController(text: project.hourlyRate.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Project'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: clientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Client Name',
                    icon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a client name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: hourlyRateController,
                  decoration: const InputDecoration(
                    labelText: 'Hourly Rate (\$)',
                    icon: Icon(Icons.attach_money),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an hourly rate';
                    }
                    try {
                      final rate = double.parse(value);
                      if (rate <= 0) {
                        return 'Rate must be greater than zero';
                      }
                    } catch (e) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
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
                if (formKey.currentState?.validate() ?? false) {
                  try {
                    final updatedProject = project.copyWith(
                      clientName: clientNameController.text.trim(),
                      hourlyRate: double.parse(hourlyRateController.text),
                    );

                    // Update the project
                    ref
                        .read(projectsProvider.notifier)
                        .updateProject(updatedProject);

                    debugPrint(
                        '✅ Project updated successfully: ${updatedProject.clientName}');

                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Project updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    debugPrint('❌ Error updating project: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating project: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

// Delete project confirmation dialog
  void _deleteProject(BuildContext context, WidgetRef ref, Project project) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: Text(
              'Are you sure you want to delete "${project.clientName}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                try {
                  // Delete the project
                  ref.read(projectsProvider.notifier).deleteProject(project.id);

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Project deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  debugPrint('❌ Error deleting project: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting project: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

// Export invoice
  void _exportInvoice(BuildContext context, Project project) {
    try {
      // Show a loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating invoice...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Generate and export the invoice
      InvoiceService.generateInvoice(project).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating invoice: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } catch (e) {
      debugPrint('❌ Error preparing invoice export: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error preparing invoice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
  //   return Row(
  //     children: [
  //       Icon(
  //         icon,
  //         size: 16,
  //         color: Theme.of(context).colorScheme.primary,
  //       ),
  //       const SizedBox(width: 4),
  //       Text(
  //         text,
  //         style: Theme.of(context).textTheme.bodyMedium,
  //       ),
  //     ],
  //   );
  // }
}
