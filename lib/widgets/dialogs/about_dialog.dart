// widgets/dialogs/about_dialog.dart
import 'package:flutter/material.dart';

class AboutAppDialog {
  static void show(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Expenses Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.account_balance_wallet, size: 48),
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'A simple and efficient way to track your income and expenses. Organize your transactions with custom categories and get insights into your spending habits.',
          ),
        ),
      ],
    );
  }
}