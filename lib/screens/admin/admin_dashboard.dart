// screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/match.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionCard(
              title: 'Fetch Latest Matches',
              description:
                  'Get the latest matches from the Odds API and create tips',
              actionText: 'FETCH DATA',
              onPressed: _fetchLatestMatches,
            ),
            if (_message != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _message!.contains('Error')
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_message!),
              ),
            const SizedBox(height: 24),
            const Text(
              'Other Admin Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'View Pending Matches',
              description: 'See matches that need results',
              actionText: 'VIEW MATCHES',
              onPressed: () {
                // Navigate to pending matches screen
              },
            ),
            _buildActionCard(
              title: 'Manual Tip Creation',
              description: 'Create tips manually for specific matches',
              actionText: 'CREATE TIP',
              onPressed: () {
                // Navigate to tip creation screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : onPressed,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchLatestMatches() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      List<Match> matches = await _firebaseService.fetchAndStoreMatches();

      setState(() {
        _isLoading = false;
        _message = 'Successfully fetched ${matches.length} matches';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error: $e';
      });
    }
  }
}
