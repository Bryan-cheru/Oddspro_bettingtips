import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tip.dart';
import '../widgets/tip_card.dart';
import '../widgets/category_grid.dart';
import '../services/api_services.dart';

class FreeTipsScreen extends StatefulWidget {
  const FreeTipsScreen({super.key});

  @override
  _FreeTipsScreenState createState() => _FreeTipsScreenState();
}

class _FreeTipsScreenState extends State<FreeTipsScreen> {
  List<Tip> _tips = [];
  bool _isLoading = true;
  String? _error;
  String _currentCategory = 'All Tips';

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiServices = Provider.of<ApiServices>(context, listen: false);

      // Load tips based on the current category
      List<Tip> tips;
      if (_currentCategory == 'All Tips') {
        tips = await apiServices.getFreeTips(forceRefresh: true);
      } else if (_currentCategory == 'Sure Bets') {
        tips = await apiServices.getSureBets();
      } else if (_currentCategory == 'Under Tips') {
        tips = await apiServices.getUnderTips();
      } else if (_currentCategory == 'Over Tips') {
        tips = await apiServices.getOverTips();
      } else if (_currentCategory == 'GG Tips') {
        tips = await apiServices.getBTTS();
      } else {
        tips = await apiServices.getFreeTips();
      }

      setState(() {
        _tips = tips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load tips: $e';
        _isLoading = false;
      });
      print('Error loading tips: $e');
    }
  }

  void _handleCategoryTap(int index) {
    final categories = ['Sure Bets', 'Under Tips', 'Over Tips', 'GG Tips'];
    if (index >= 0 && index < categories.length) {
      setState(() {
        _currentCategory = categories[index];
      });
      _loadTips();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          // 100% Guaranteed Matches Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            color: Colors.blue.shade700,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  '100% GUARANTEED MATCHES',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Category grid
          CategoryGrid(
            categories: [
              CategoryItem(
                title: 'Sure Bets',
                icon: Icons.verified_user,
                customColor: const Color(0xFF4361EE),
              ),
              CategoryItem(
                title: 'Under Tips',
                icon: Icons.arrow_downward,
                customColor: const Color(0xFF3A0CA3),
              ),
              CategoryItem(
                title: 'Over Tips',
                icon: Icons.arrow_upward,
                customColor: const Color(0xFF7209B7),
              ),
              CategoryItem(
                title: 'GG Tips',
                icon: Icons.sports_soccer,
                customColor: const Color(0xFFB5179E),
              ),
            ],
            onCategoryTap: _handleCategoryTap,
          ),

          // Current category indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Showing: $_currentCategory',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),

          // Tips list
          Expanded(
            child: _buildTipsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsList() {
    if (_isLoading && _tips.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_error != null && _tips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTips,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_tips.isEmpty) {
      return Center(
        child: Text(
          'No tips available for $_currentCategory',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTips,
      color: Theme.of(context).primaryColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _tips.length,
        itemBuilder: (context, index) {
          return TipCard(tip: _tips[index]);
        },
      ),
    );
  }
}