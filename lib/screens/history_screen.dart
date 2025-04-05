import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tip.dart';
import '../widgets/tip_card.dart';
import '../services/api_services.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Tip> _historyTips = [];
  bool _isLoading = true;
  String? _error;

  // In a real app with a backend, you would fetch historical tips
  // For this demo, we'll use all tips and add some random results

  @override
  void initState() {
    super.initState();
    _loadHistoryTips();
  }

  Future<void> _loadHistoryTips() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiServices = Provider.of<ApiServices>(context, listen: false);

      // Get a mix of free and premium tips
      List<Tip> freeTips = await apiServices.getFreeTips();
      List<Tip> premiumTips = await apiServices.getPremiumTips();

      // Combine tips
      List<Tip> allTips = [...freeTips, ...premiumTips];

      // Simulate completed tips with results
      List<Tip> historicalTips = allTips.map((tip) {
        // Create a copy with results
        bool isWin = DateTime.now().millisecondsSinceEpoch % 2 == 0; // Random win/loss

        // Create a new tip with the same properties plus a result
        return Tip(
          id: tip.id,
          match: tip.match,
          prediction: tip.prediction,
          odds: tip.odds,
          result: isWin ? TipResult.win : TipResult.loss,
          score: '${tip.match.homeScore ?? 1}-${tip.match.awayScore ?? 0}', // Random score
          isPremium: tip.isPremium,
          category: tip.category,
        );
      }).toList();

      setState(() {
        _historyTips = historicalTips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load history: $e';
        _isLoading = false;
      });
      print('Error loading history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          // History Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            color: Colors.blue.shade700,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'BETTING HISTORY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Filters (can be expanded in a real app)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip('All', true),
                _buildFilterChip('Wins', false),
                _buildFilterChip('Losses', false),
              ],
            ),
          ),

          // Tips list
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey.shade700,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_error != null) {
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
              onPressed: _loadHistoryTips,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_historyTips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: Colors.white.withOpacity(0.5), size: 64),
            const SizedBox(height: 16),
            const Text(
              'No betting history available',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistoryTips,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historyTips.length,
        itemBuilder: (context, index) {
          return TipCard(
            tip: _historyTips[index],
            showResult: true, // Show the result in the card
          );
        },
      ),
    );
  }
}