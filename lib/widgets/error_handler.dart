import 'package:flutter/material.dart';

/// A widget that wraps any potentially problematic widget to catch and display errors
class ErrorHandler extends StatefulWidget {
  final Widget child;
  final String widgetName;

  const ErrorHandler({
    super.key,
    required this.child,
    required this.widgetName,
  });

  @override
  State<ErrorHandler> createState() => _ErrorHandlerState();
}

class _ErrorHandlerState extends State<ErrorHandler> {
  @override
  void initState() {
    super.initState();
    // Set a custom error widget builder to show detailed error information
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };
  }

  @override
  Widget build(BuildContext context) {
    // Use ErrorBoundary pattern
    return Builder(
      builder: (context) {
        try {
          return widget.child;
        } catch (error, stackTrace) {
          return _buildErrorWidget(error, stackTrace);
        }
      },
    );
  }

  Widget _buildErrorWidget(Object error, StackTrace stackTrace) {
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
          Text(
            'Error in ${widget.widgetName}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(color: Colors.red.shade900),
          ),
          const SizedBox(height: 8),
          Container(
            height: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SingleChildScrollView(
              child: Text(
                stackTrace.toString(),
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
  }
}
