// services/stripe_payment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

enum SubscriptionPlan {
  monthly,
  quarterly,
  annual,
}

class SubscriptionInfo {
  final bool isActive;
  final DateTime? expiryDate;
  final SubscriptionPlan? plan;
  final String? subscriptionId;
  final String? customerId;

  SubscriptionInfo({
    required this.isActive,
    this.expiryDate,
    this.plan,
    this.subscriptionId,
    this.customerId,
  });
}

class StripePaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Replace with your own backend URL - ideally stored in environment variables
  final String backendUrl = 'https://your-stripe-server.com';

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Initialize Stripe - call this in your app initialization
  static Future<void> initialize() async {
    // Replace with your own publishable key
    Stripe.publishableKey = 'pk_test_your_publishable_key_here';
    await Stripe.instance.applySettings();
  }

  // Get current subscription status
  Future<SubscriptionInfo> getSubscriptionStatus() async {
    try {
      if (currentUserId == null) {
        return SubscriptionInfo(isActive: false);
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if (!userDoc.exists) {
        return SubscriptionInfo(isActive: false);
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      // Check subscription data
      if (!userData.containsKey('subscription') ||
          userData['subscription'] == null) {
        return SubscriptionInfo(isActive: false);
      }

      final subscription = userData['subscription'] as Map<String, dynamic>;

      // Parse expiry date
      DateTime? expiryDate;
      if (subscription.containsKey('expiryDate') &&
          subscription['expiryDate'] != null) {
        expiryDate = (subscription['expiryDate'] as Timestamp).toDate();
      }

      // Check if subscription is active
      bool isActive = false;
      if (expiryDate != null) {
        isActive = expiryDate.isAfter(DateTime.now());
      }

      // Parse plan
      SubscriptionPlan? plan;
      if (subscription.containsKey('plan') &&
          subscription['plan'] != null) {
        switch (subscription['plan']) {
          case 'monthly':
            plan = SubscriptionPlan.monthly;
            break;
          case 'quarterly':
            plan = SubscriptionPlan.quarterly;
            break;
          case 'annual':
            plan = SubscriptionPlan.annual;
            break;
        }
      }

      return SubscriptionInfo(
        isActive: isActive,
        expiryDate: expiryDate,
        plan: plan,
        subscriptionId: subscription['subscriptionId'],
        customerId: subscription['customerId'],
      );
    } catch (e) {
      print('Error getting subscription status: $e');
      return SubscriptionInfo(isActive: false);
    }
  }

  // Start subscription flow
  Future<bool> startSubscription(SubscriptionPlan plan) async {
    try {
      // First ensure the user is logged in
      if (currentUserId == null) {
        throw Exception('User must be logged in to subscribe');
      }

      // Get price ID based on the plan
      String priceId = _getPriceIdForPlan(plan);

      // 1. Create payment intent on the server
      final response = await http.post(
        Uri.parse('$backendUrl/create-subscription'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'priceId': priceId,
          'userId': currentUserId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create subscription: ${response.body}');
      }

      final responseData = json.decode(response.body);

      // 2. Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: responseData['clientSecret'],
          merchantDisplayName: 'ODDSPRO AI',
          customerId: responseData['customer'],
          customerEphemeralKeySecret: responseData['ephemeralKey'],
        ),
      );

      // 3. Present payment sheet to user
      await Stripe.instance.presentPaymentSheet();

      // 4. Handle successful payment
      await _onSubscriptionSuccess(
        plan,
        responseData['subscriptionId'],
        responseData['customer'],
      );

      return true;
    } catch (e) {
      print('Error starting subscription: $e');
      if (e is StripeException) {
        // Handle specific Stripe errors
        print('Stripe error: ${e.error.localizedMessage}');
      }
      return false;
    }
  }

  // Cancel subscription
  Future<bool> cancelSubscription() async {
    try {
      // First get current subscription info
      final subscriptionInfo = await getSubscriptionStatus();

      if (!subscriptionInfo.isActive ||
          subscriptionInfo.subscriptionId == null) {
        return false;
      }

      // Call backend to cancel subscription
      final response = await http.post(
        Uri.parse('$backendUrl/cancel-subscription'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'subscriptionId': subscriptionInfo.subscriptionId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel subscription: ${response.body}');
      }

      // Update user data in Firestore
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update({
        'subscription.isActive': false,
        'subscription.canceledAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error canceling subscription: $e');
      return false;
    }
  }

  // Get price ID for subscription plan
  String _getPriceIdForPlan(SubscriptionPlan plan) {
    // Replace with your actual Stripe price IDs
    switch (plan) {
      case SubscriptionPlan.monthly:
        return 'price_monthly_id_here';
      case SubscriptionPlan.quarterly:
        return 'price_quarterly_id_here';
      case SubscriptionPlan.annual:
        return 'price_annual_id_here';
    }
  }

  // Handle successful subscription
  Future<void> _onSubscriptionSuccess(
      SubscriptionPlan plan,
      String subscriptionId,
      String customerId,
      ) async {
    try {
      // Calculate expiry date based on plan
      DateTime now = DateTime.now();
      DateTime expiryDate;

      switch (plan) {
        case SubscriptionPlan.monthly:
          expiryDate = DateTime(now.year, now.month + 1, now.day);
          break;
        case SubscriptionPlan.quarterly:
          expiryDate = DateTime(now.year, now.month + 3, now.day);
          break;
        case SubscriptionPlan.annual:
          expiryDate = DateTime(now.year + 1, now.month, now.day);
          break;
      }

      // Convert plan to string
      String planStr;
      switch (plan) {
        case SubscriptionPlan.monthly:
          planStr = 'monthly';
          break;
        case SubscriptionPlan.quarterly:
          planStr = 'quarterly';
          break;
        case SubscriptionPlan.annual:
          planStr = 'annual';
          break;
      }

      // Save subscription info to Firebase
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set({
        'subscription': {
          'isActive': true,
          'plan': planStr,
          'subscriptionId': subscriptionId,
          'customerId': customerId,
          'startDate': FieldValue.serverTimestamp(),
          'expiryDate': Timestamp.fromDate(expiryDate),
          'lastUpdated': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving subscription data: $e');
    }
  }
}