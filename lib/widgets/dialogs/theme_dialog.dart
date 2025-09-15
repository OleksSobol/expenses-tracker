// widgets/dialogs/theme_dialog.dart
import 'package:flutter/material.dart';

class ThemeDialog {
  static void show({
    required BuildContext context,
    required ThemeMode currentThemeMode,
    required Function(ThemeMode) onThemeChanged,
  }) {
    showDialog(
      context: context,
      builder: (context) => _ThemeDialogContent(
        currentThemeMode: currentThemeMode,
        onThemeChanged: onThemeChanged,
      ),
    );
  }
}

class _ThemeDialogContent extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;

  const _ThemeDialogContent({
    required this.currentThemeMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Choose Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            context: context,
            title: 'Light Theme',
            subtitle: 'Always use light mode',
            icon: Icons.light_mode,
            mode: ThemeMode.light,
            isSelected: currentThemeMode == ThemeMode.light,
            onTap: () {
              onThemeChanged(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 8),
          _buildThemeOption(
            context: context,
            title: 'Dark Theme',
            subtitle: 'Always use dark mode',
            icon: Icons.dark_mode,
            mode: ThemeMode.dark,
            isSelected: currentThemeMode == ThemeMode.dark,
            onTap: () {
              onThemeChanged(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 8),
          _buildThemeOption(
            context: context,
            title: 'System Theme',
            subtitle: 'Follow system setting',
            icon: Icons.auto_mode,
            mode: ThemeMode.system,
            isSelected: currentThemeMode == ThemeMode.system,
            onTap: () {
              onThemeChanged(ThemeMode.system);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.onSurface,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}