import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DeleteConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const DeleteConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppTheme.textDark,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        content,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppTheme.textMedium,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorRed,
            foregroundColor: Colors.white,
          ),
          child: const Text('Elimina'),
        ),
      ],
    );
  }
}