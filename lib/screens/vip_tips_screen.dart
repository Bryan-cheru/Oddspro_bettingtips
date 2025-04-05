import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/category_grid.dart';
import '../widgets/tip_card.dart';
import '../config/theme.dart';
import '../models/tip.dart';
import '../services/api_services.dart';
import 'subscription_screen.dart';

class VipTipsScreen extends StatefulWidget {
  const VipTipsScreen({super.key});

  @override
  _VipTipsScreenState createState() => _VipTipsScreenState();
}

class _VipTipsScreenState extends State<VipTipsScreen> {
  bool _isLoading = false;
  String? _error;
  List<Tip> _premiumTips = [];
  String _currentCategory = 'Premium Tips';
  bool _isSubscribed = false; // In real app, check user subscription status

  @override
  void initState() {
    super.initState();
    _checkSubscription();
    _loadPremiumTips();
  }

  // Check if user is subscribed - in a real app, this would check with your payment provider
  Future<void> _checkSubscription() async {
    // For demo purposes, we're setting this to false
    // In a real app, you'd check with Firebase or your payment provider
    setState(() {
      _isSubscribed = false;
    });
  }

  Future<void> _loadPremiumTips() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiServices = Provider.of<ApiServices>(context, listen: false);

      // Load tips based on the current category
      List<Tip> tips;
      if (_currentCategory == 'Premium Tips') {
        tips = await apiServices.getPremiumTips();
      } else if (_currentCategory == 'Daily 2+ Odds') {
        tips = await apiServices.getDailyHighOdds();
      } else if (_currentCategory == 'Super Draws') {
        tips = await apiServices.getSuperDraws();
      } else {
        tips = await apiServices.getPremiumTips();
      }

      setState(() {
        _premiumTips = tips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load premium tips: $e';
        _isLoading = false;
      });
      print('Error loading premium tips: $e');
    }
  }

  void _handleCategoryTap(int index) {
    final categories = [
      'Daily 2+ Odds',
      'Super Draws',
      'Premium Tips',
      'EPL VIP',
      'HT/FT VIP',
      'SPECIAL VVIP+'
    ];

    if (index >= 0 && index < categories.length) {
      setState(() {
        _currentCategory = categories[index];
      });
      _loadPremiumTips();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgColor,
      child: _isSubscribed ? _buildSubscribedContent() : _buildSubscriptionPrompt(),
    );
  }

  Widget _buildSubscribedContent() {
    return Column(
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
                '100% GUARANTEED PREMIUM MATCHES',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // VIP Categories grid
        CategoryGrid(
          categories: [
            CategoryItem(
              title: 'Daily 2+ Odds',
              icon: Icons.access_time_filled,
              customColor: const Color(0xFF5E60CE),
            ),
            CategoryItem(
              title: 'Super Draws',
              icon: Icons.emoji_events,
              customColor: const Color(0xFF5390D9),
            ),
            CategoryItem(
              title: 'Premium Tips',
              icon: Icons.star,
              customColor: const Color(0xFF4EA8DE),
            ),
            CategoryItem(
              title: 'EPL VIP',
              icon: Icons.sports_soccer,
              customColor: const Color(0xFF48BFE3),
            ),
            CategoryItem(
              title: 'HT/FT VIP',
              icon: Icons.timer,
              customColor: const Color(0xFF56CFE1),
            ),
            CategoryItem(
              title: 'SPECIAL VVIP+',
              icon: Icons.star_border,
              customColor: const Color(0xFF64DFDF),
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

        // Premium Tips List
        Expanded(
          child: _buildPremiumTipsList(),
        ),
      ],
    );
  }

  Widget _buildPremiumTipsList() {
    if (_isLoading && _premiumTips.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_error != null && _premiumTips.isEmpty) {
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
              onPressed: _loadPremiumTips,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_premiumTips.isEmpty) {
      return Center(
        child: Text(
          'No premium tips available for $_currentCategory',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPremiumTips,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _premiumTips.length,
        itemBuilder: (context, index) {
          return TipCard(tip: _premiumTips[index]);
        },
      ),
    );
  }

  Widget _buildSubscriptionPrompt() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // VIP Categories grid
          CategoryGrid(
            categories: [
              CategoryItem(
                title: 'Daily 2+ Odds',
                icon: Icons.access_time_filled,
                customColor: const Color(0xFF5E60CE),
              ),
              CategoryItem(
                title: 'Super Draws',
                icon: Icons.emoji_events,
                customColor: const Color(0xFF5390D9),
              ),
              CategoryItem(
                title: 'Premium Tips',
                icon: Icons.star,
                customColor: const Color(0xFF4EA8DE),
              ),
              CategoryItem(
                title: 'EPL VIP',
                icon: Icons.sports_soccer,
                customColor: const Color(0xFF48BFE3),
              ),
              CategoryItem(
                title: 'HT/FT VIP',
                icon: Icons.timer,
                customColor: const Color(0xFF56CFE1),
              ),
              CategoryItem(
                title: 'SPECIAL VVIP+',
                icon: Icons.star_border,
                customColor: const Color(0xFF64DFDF),
              ),
            ],
            onCategoryTap: (index) {
              // Prompt subscription when a category is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
          ),

          // Premium subscription card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF5E17EB),
                      Color(0xFF6C4AB6),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Premium Access Required',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Unlock all VIP features',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '✓ Higher accuracy predictions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '✓ Premium customer support',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '✓ Exclusive betting strategies',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SubscriptionScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.highlightColor,
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          child: const Text('SUBSCRIBE NOW'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Success rate card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Our Success Rate',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.textDarkColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatItem(
                          context,
                          '85%',
                          'VIP Tips',
                          AppTheme.successColor,
                        ),
                        _buildStatItem(
                          context,
                          '70%',
                          'Free Tips',
                          AppTheme.secondaryColor,
                        ),
                        _buildStatItem(
                          context,
                          '90%',
                          'VVIP Tips',
                          const Color(0xFF9D4EDD),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textLightColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}