// In screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'subscription_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _newTipsNotifications = true;
  bool _resultNotifications = true;
  bool _specialOffersNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Notifications section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive all app notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('New Tips'),
            subtitle: const Text('Get notified when new tips are available'),
            value: _newTipsNotifications && _notificationsEnabled,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() {
                      _newTipsNotifications = value;
                    });
                  }
                : null,
          ),
          SwitchListTile(
            title: const Text('Results'),
            subtitle: const Text('Get notified when tip results are available'),
            value: _resultNotifications && _notificationsEnabled,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() {
                      _resultNotifications = value;
                    });
                  }
                : null,
          ),
          SwitchListTile(
            title: const Text('Special Offers'),
            subtitle:
                const Text('Get notified about promotions and special offers'),
            value: _specialOffersNotifications && _notificationsEnabled,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() {
                      _specialOffersNotifications = value;
                    });
                  }
                : null,
          ),

          // App settings section
          _buildSectionHeader('App Settings'),
          ListTile(
            title: const Text('Clear Cache'),
            subtitle:
                const Text('Free up space by clearing locally stored data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Cache'),
                  content: const Text(
                      'Are you sure you want to clear the app cache?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Clear cache logic
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Current',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),

          // Account section
          _buildSectionHeader('Account'),
          ListTile(
            title: const Text('Premium Subscription'),
            subtitle: const Text('Manage your premium subscription'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to subscription screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
