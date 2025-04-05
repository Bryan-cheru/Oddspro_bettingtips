import 'package:flutter/material.dart';
import '../services/stripe_payment_service.dart';
import 'package:intl/intl.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlanIndex = 1; // Default to the middle plan
  bool _isLoading = false;
  SubscriptionInfo? _subscriptionInfo;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final stripeService = StripePaymentService();
      final subscriptionInfo = await stripeService.getSubscriptionStatus();

      setState(() {
        _subscriptionInfo = subscriptionInfo;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading subscription status: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _subscribe() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final stripeService = StripePaymentService();
      SubscriptionPlan plan;

      // Map selected index to plan
      switch (_selectedPlanIndex) {
        case 0:
          plan = SubscriptionPlan.monthly;
          break;
        case 1:
          plan = SubscriptionPlan.quarterly;
          break;
        case 2:
          plan = SubscriptionPlan.annual;
          break;
        default:
          plan = SubscriptionPlan.monthly;
      }

      final success = await stripeService.startSubscription(plan);

      if (success) {
        // Refresh subscription status
        await _loadSubscriptionStatus();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription failed. Please try again.')),
        );
      }
    } catch (e) {
      print('Error subscribing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelSubscription() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final stripeService = StripePaymentService();
      final success = await stripeService.cancelSubscription();

      if (success) {
        // Refresh subscription status
        await _loadSubscriptionStatus();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription canceled successfully.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel subscription. Please try again.'),
          ),
        );
      }
    } catch (e) {
      print('Error canceling subscription: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Subscription'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subscriptionInfo != null && _subscriptionInfo!.isActive
          ? _buildActiveSubscription()
          : _buildSubscriptionPlans(),
    );
  }

  Widget _buildActiveSubscription() {
    // Format expiry date
    String expiryDateStr = 'Unknown';
    if (_subscriptionInfo?.expiryDate != null) {
      expiryDateStr = DateFormat('MMMM dd, yyyy').format(_subscriptionInfo!.expiryDate!);
    }

    // Get plan name
    String planName = 'Unknown';
    if (_subscriptionInfo?.plan != null) {
      switch (_subscriptionInfo!.plan!) {
        case SubscriptionPlan.monthly:
          planName = 'Monthly';
          break;
        case SubscriptionPlan.quarterly:
          planName = 'Quarterly';
          break;
        case SubscriptionPlan.annual:
          planName = 'Annual';
          break;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active subscription banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 50,
                ),
                SizedBox(height: 12),
                Text(
                  'Active Subscription',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Subscription details
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subscription Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Plan', planName),
                  _buildDetailRow('Status', 'Active'),
                  _buildDetailRow('Expiry Date', expiryDateStr),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Benefits',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBenefitRow('Access to all VIP tips'),
                  _buildBenefitRow('Premium customer support'),
                  _buildBenefitRow('Exclusive betting strategies'),
                  if (_subscriptionInfo?.plan == SubscriptionPlan.annual)
                    _buildBenefitRow('Betting strategy guide'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Cancel subscription button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _cancelSubscription,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'CANCEL SUBSCRIPTION',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          const Text(
            'Your subscription will remain active until the expiry date.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(benefit),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans() {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
    child: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Header
    Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
    color: Theme.of(context).primaryColor,
    borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
    children: [
    const Icon(
    Icons.star,
    color: Colors.amber,
    size: 50,
    ),
    const SizedBox(width: 16),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    'Unlock Premium Features',
    style: TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 8),
    Text(
    'Get access to VIP tips and advanced features',
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
    ),

    const SizedBox(height: 24),

    const Text(
    'Choose Your Plan',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),

    const SizedBox(height: 16),

    // Monthly Plan
    _buildPlanCard(
    0,
    'Monthly',
    '9.99',
    'per month',
    null,
    ['Access to all VIP tips', 'Email support', 'Cancel anytime'],
    false,
    ),

    // Quarterly Plan
    _buildPlanCard(
    1,
    'Quarterly',
    '24.99',
    'every 3 months',
    17,
    [
    'Access to all VIP tips',
    'Priority email support',
    'Special promotions',
    'Cancel anytime',
    ],
    true,
    ),

      // Annual Plan
      _buildPlanCard(
        2,
        'Annual',
        '89.99',
        'per year',
        25,
        [
          'Access to all VIP & VVIP tips',
          'Priority support',
          'Special promotions',
          'Betting strategy guide',
          'Cancel anytime',
        ],
        false,
      ),

      const SizedBox(height: 24),

      // Money-back guarantee
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.verified,
              color: Colors.green,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '7-day money-back guarantee if you are not satisfied.',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
    ),
    ),
    );
  }

  Widget _buildPlanCard(
      int index,
      String title,
      String price,
      String period,
      int? discount,
      List<String> features,
      bool popular,
      ) {
    final isSelected = _selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent,
            width: 2,
          ),
        ),
        elevation: isSelected ? 4 : 1,
        child: Column(
          children: [
            // Popular badge
            if (popular)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: const Text(
                  'MOST POPULAR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        '\$',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        period,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  // Discount badge
                  if (discount != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Save $discount%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Features
                  for (var feature in features)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(feature),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Subscribe button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        if (isSelected) {
                          _subscribe();
                        } else {
                          setState(() {
                            _selectedPlanIndex = index;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.grey.withOpacity(0.2),
                        foregroundColor:
                        isSelected ? Colors.white : Colors.black,
                      ),
                      child: _isLoading && isSelected
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        isSelected ? 'SUBSCRIBE NOW' : 'SELECT PLAN',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}