import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  ThemeMode _themeMode = ThemeMode.system;
  String _measurementSystem = 'Metric';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            'Appearance',
            [
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(_getThemeText()),
                leading: const Icon(Icons.palette),
                onTap: _showThemeDialog,
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme'),
                secondary: const Icon(Icons.dark_mode),
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (bool value) {
                  // TODO: Implement theme switching
                },
              ),
            ],
          ),
          _buildSection(
            'Notifications',
            [
              SwitchListTile(
                title: const Text('Email Notifications'),
                subtitle: const Text('Receive email updates'),
                secondary: const Icon(Icons.email),
                value: _emailNotifications,
                onChanged: (bool value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive push notifications'),
                secondary: const Icon(Icons.notifications),
                value: _pushNotifications,
                onChanged: (bool value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),
            ],
          ),
          _buildSection(
            'Preferences',
            [
              ListTile(
                title: const Text('Measurement System'),
                subtitle: Text(_measurementSystem),
                leading: const Icon(Icons.straighten),
                onTap: _showMeasurementSystemDialog,
              ),
            ],
          ),
          _buildSection(
            'Account',
            [
              ListTile(
                title: const Text('Email'),
                subtitle: Text(
                  context.read<AuthService>().currentUser?.email ?? '',
                ),
                leading: const Icon(Icons.email),
              ),
              ListTile(
                title: const Text('Change Password'),
                leading: const Icon(Icons.lock),
                onTap: () {
                  // TODO: Implement password change
                },
              ),
              ListTile(
                title: Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                onTap: _showDeleteAccountDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  String _getThemeText() {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  Future<void> _showThemeDialog() async {
    final ThemeMode? result = await showDialog<ThemeMode>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose Theme'),
          children: <Widget>[
            _buildThemeOption(ThemeMode.system, 'System'),
            _buildThemeOption(ThemeMode.light, 'Light'),
            _buildThemeOption(ThemeMode.dark, 'Dark'),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _themeMode = result;
      });
    }
  }

  Widget _buildThemeOption(ThemeMode mode, String text) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context, mode);
      },
      child: Text(text),
    );
  }

  Future<void> _showMeasurementSystemDialog() async {
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose Measurement System'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Metric');
              },
              child: const Text('Metric'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Imperial');
              },
              child: const Text('Imperial'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _measurementSystem = result;
      });
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await context.read<AuthService>().deleteAccount();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
