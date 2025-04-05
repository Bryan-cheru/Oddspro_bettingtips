import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../widgets/navigation_bar.dart';
import 'free_tips_screen.dart';
import 'vip_tips_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'subscription_screen.dart';
import 'faq_screen.dart';
import 'privacy_policy_screen.dart';
import 'admin/admin_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final bool _isAdmin = false; // Update with actual admin check logic

  @override
  void initState() {
    super.initState();
    // Pre-fetch data when the app starts for faster display
    _preloadData();
  }

  // Preload data in the background
  Future<void> _preloadData() async {
    try {
      final apiServices = Provider.of<ApiServices>(context, listen: false);
      // Load free tips in the background
      apiServices.getFreeTips();
    } catch (e) {
      print('Error preloading data: $e');
    }
  }

  // Screens are created on demand to avoid keeping multiple instances
  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const FreeTipsScreen();
      case 1:
        return const VipTipsScreen();
      case 2:
        return const HistoryScreen();
      default:
        return const FreeTipsScreen();
    }
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          CustomNavigationBar(
            selectedIndex: _selectedIndex,
            onTabSelected: _onTabSelected,
          ),
          // Removed banner since each screen now has its own banner
          Expanded(child: _getCurrentScreen()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('ODDSPRO TIPS'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Handle notifications
          },
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onTabSelected,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_soccer),
          label: 'Free Tips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'VIP Tips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          _buildDrawerItem(Icons.sports_soccer, 'Free Tips', 0),
          _buildDrawerItem(Icons.star, 'VIP Tips', 1),
          _buildDrawerItem(Icons.history, 'History', 2),
          const Divider(),
          _buildDrawerNavigation(Icons.paid, 'Premium', const SubscriptionScreen()),
          _buildDrawerNavigation(Icons.settings, 'Settings', const SettingsScreen()),
          const Divider(),
          _buildDrawerNavigation(Icons.help_outline, 'FAQs', const FAQScreen()),
          _buildDrawerNavigation(Icons.privacy_tip_outlined, 'Privacy Policy',
              const PrivacyPolicyScreen()),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
          if (_isAdmin) ...[
            const Divider(),
            _buildDrawerNavigation(Icons.admin_panel_settings,
                'Admin Dashboard', const AdminDashboard()),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Data'),
            onTap: () {
              Navigator.pop(context);
              _refreshAllData(context);
            },
          ),
        ],
      ),
    );
  }

  // Added function to refresh all API data
  Future<void> _refreshAllData(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing data...')),
    );

    try {
      final apiServices = Provider.of<ApiServices>(context, listen: false);
      await apiServices.refreshAllData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data refreshed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing data: $e')),
      );
    }
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'ODDSPRO TIPS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Professional Betting Tips',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () {
        _onTabSelected(index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildDrawerNavigation(IconData icon, String title, Widget screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'OddsPro AI',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.sports_soccer,
        size: 48,
        color: Theme.of(context).primaryColor,
      ),
      applicationLegalese: '© 2025 OddsPro AI. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'OddsPro Bettingtips provides expert betting tips based on in-depth analysis to help you make informed betting decisions.',
        ),
        const SizedBox(height: 8),
        const Text(
          'Powered by The Odds API - bringing you the most accurate betting data.',
        ),
      ],
    );
  }
}