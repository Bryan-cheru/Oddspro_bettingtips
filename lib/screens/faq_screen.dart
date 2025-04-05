// screens/faq_screen.dart
import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFAQItem(
            context,
            'What is OddsPro AI?',
            'OddsPro AI is a professional betting tips app that utilizes advanced algorithms and statistical analysis to provide high-quality sports prediction tips.',
          ),
          _buildFAQItem(
            context,
            'How accurate are the predictions?',
            'Our predictions are based on comprehensive data analysis and have a success rate of approximately 70%. However, please note that sports betting always involves an element of uncertainty.',
          ),
          _buildFAQItem(
            context,
            'How often are new tips added?',
            'We add new tips daily, focusing on major leagues and competitions around the world.',
          ),
          _buildFAQItem(
            context,
            'What is the difference between Free and VIP tips?',
            'Free tips are available to all users and cover basic predictions. VIP tips include premium predictions with higher accuracy rates, special events coverage, and exclusive betting strategies.',
          ),
          _buildFAQItem(
            context,
            'How do I subscribe to VIP tips?',
            'You can subscribe to VIP tips by going to the Premium section in the app and choosing a subscription plan that suits you.',
          ),
          _buildFAQItem(
            context,
            'Can I get a refund if I\'m not satisfied?',
            'Yes, we offer a 7-day money-back guarantee if you\'re not satisfied with our VIP service.',
          ),
          _buildFAQItem(
            context,
            'How can I contact support?',
            'You can reach our support team at support@oddsproai.com or through the contact form in the app.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
