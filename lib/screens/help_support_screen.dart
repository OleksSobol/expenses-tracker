import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  _HelpSupportScreenState createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  
  String _selectedSubject = 'General Question';
  bool _includeDeviceInfo = true;

  final List<String> _subjects = [
    'General Question',
    'Feature Request',
    'Bug Report',
    'Data Export/Import Help',
    'Category Management Help',
    'Sync Issues',
    'App Crashes',
    'Performance Issues',
    'Other',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<String> _getDeviceInfo() async {
    if (!_includeDeviceInfo) return '';

    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      
      String deviceDetails = '\n\n--- Device Information ---\n';
      deviceDetails += 'App Version: ${packageInfo.version} (${packageInfo.buildNumber})\n';
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceDetails += 'Platform: Android ${androidInfo.version.release}\n';
        deviceDetails += 'Device: ${androidInfo.brand} ${androidInfo.model}\n';
        deviceDetails += 'Android SDK: ${androidInfo.version.sdkInt}\n';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceDetails += 'Platform: iOS ${iosInfo.systemVersion}\n';
        deviceDetails += 'Device: ${iosInfo.model}\n';
        deviceDetails += 'Name: ${iosInfo.name}\n';
      }
      
      return deviceDetails;
    } catch (e) {
      return '\n\n--- Device Information ---\nUnable to collect device info';
    }
  }

  Future<void> _sendEmail() async {
  if (!_formKey.currentState!.validate()) return;

  final deviceInfo = await _getDeviceInfo();

  final emailUri = Uri(
    scheme: 'mailto',
    path: 'support@expensestracker.com',
    queryParameters: {
      'subject': 'Expenses Tracker - $_selectedSubject',
      'body': '${_messageController.text}\n$deviceInfo\n\n--- Contact Info ---\nEmail: (please add your email)',
    },
  );

  try {
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email app opened!')),
        );
        _messageController.clear();
        setState(() => _selectedSubject = 'General Question');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No email app found. Please email support@expensestracker.com directly or check your email app settings.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to open email app: $e. Please email support@expensestracker.com manually.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Help Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Quick Help',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _buildQuickHelpItem(
                        'Adding Categories',
                        'Go to Settings → Manage Categories → Add new category with custom icon and color',
                      ),
                      _buildQuickHelpItem(
                        'Filtering Transactions',
                        'Use the filter bar on home screen to sort by type, category, or amount',
                      ),
                      _buildQuickHelpItem(
                        'Editing Transactions',
                        'Tap any transaction in the list to edit or delete it',
                      ),
                      _buildQuickHelpItem(
                        'Dark Mode',
                        'Go to Settings → Theme to switch between light, dark, or system theme',
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Contact Form Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.email, color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: 8),
                            Text(
                              'Contact Us',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Have a question, suggestion, or found a bug? We\'d love to hear from you!',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),

                        SizedBox(height: 20),

                        // Subject dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedSubject,
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.subject),
                          ),
                          items: _subjects.map((subject) {
                            return DropdownMenuItem(
                              value: subject,
                              child: Text(subject),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSubject = value;
                              });
                            }
                          },
                        ),

                        SizedBox(height: 16),

                        // Message field
                        TextFormField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            labelText: 'Message',
                            hintText: 'Please describe your question, issue, or suggestion in detail...',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.message),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your message';
                            }
                            if (value.trim().length < 10) {
                              return 'Please provide more details (at least 10 characters)';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16),

                        // Include device info checkbox
                        CheckboxListTile(
                          value: _includeDeviceInfo,
                          onChanged: (value) {
                            setState(() {
                              _includeDeviceInfo = value ?? true;
                            });
                          },
                          title: Text('Include device information'),
                          subtitle: Text(
                            'Helps us provide better support (device model, app version, etc.)',
                            style: TextStyle(fontSize: 12),
                          ),
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),

                        SizedBox(height: 20),

                        // Send button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _sendEmail,
                            icon: Icon(Icons.send),
                            label: Text('Send Message'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Alternative contact info
              Card(
                elevation: 1,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Other Ways to Reach Us',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.email, size: 20, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          InkWell(
                            onTap: () async {
                              await Clipboard.setData(ClipboardData(text: 'support@expensestracker.com'));
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Email copied to clipboard!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'support@expensestracker.com',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 20, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text('We typically respond within 24 hours'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickHelpItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}