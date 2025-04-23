import 'package:flutter/material.dart';

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App logo
            Image.asset(
              'assets/logo.png',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 16),
            // App name
            Text(
              'Time Tracker Pro',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            // App version
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            // App description
            Text(
              'A professional time tracking application for freelancers and small businesses. '
              'Track your work hours, manage projects, and generate invoices.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            // Copyright notice
            Text(
              '© 2023 Time Tracker Pro',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            // Close button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

void showAboutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const AboutAppDialog(),
  );
}
