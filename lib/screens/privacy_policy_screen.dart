// screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRIVACY POLICY',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Last Updated: [Date]', // Replace [Date] with the actual date
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 24),
            PrivacyPolicyText(),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyText extends StatelessWidget {
  const PrivacyPolicyText({super.key});
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
      '1. Introduction',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 8),
    Text(
    'OddsPro Bettingtips ("we," "our," or "us") is committed to protecting the privacy of our users ("you" or "user"). This Privacy Policy outlines how we collect, use, disclose, and safeguard your information when you access and use our mobile application (the "App"). By accessing or using the App, you acknowledge that you have read, understood, and agree to be bound by the terms of this Privacy Policy. If you do not agree to the terms of this policy, please do not use our app.',
    ),
    SizedBox(height: 16),
    Text(
    '2. Information We Collect',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 8),
    Text(
    'We collect information about you in various ways:\n\n'
    '• Personal Data: When you create an account, we may collect your name, email address, and other contact information. If you subscribe to premium services, we may also collect payment information.\n\n'
    '• Usage Data: We automatically collect information about how you interact with our App, including the pages you view, the time spent on those pages, the features you use, and the actions you take within the App.\n\n'
    '• Device Data: We may collect information about your mobile device, including device type, operating system, unique device identifiers, IP address, and mobile network information.\n\n'
    '• Betting Preferences: If you choose to provide them, we may collect data about your betting preferences and interests, so we can personalize your experience. This data is optional.\n\n'
    '• Log Data: Our servers may automatically collect log data, which includes information about your device and app activity, such as IP address, device type, app version, and timestamps.\n\n'
    '• Purchase and payment information: If you purchase a subscription, we will collect your payment information, including name, credit card information and purchase history.',
    ),
    SizedBox(height: 16),
    Text(
    '3. How We Use Your Information',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 8),
    Text(
    'We use the information we collect to:\n\n'
    '• Provide, maintain, and improve the App.\n'
    '• Process transactions and send related information, including purchase confirmations and receipts.\n'
    '• Personalize your experience and recommend relevant content or features.\n'
    '• Send you technical notices, updates, and support messages.\n'
    '• Respond to your comments and questions.\n'
    '• Develop new products and services.\n'
    '• Monitor and analyze trends, usage, and activities.\n'
    '• Detect, prevent, and address fraud and other illegal activities.\n'
    '• Comply with applicable laws and regulations.\n'
    '• Enforce our terms of service.',
    ),
    SizedBox(height: 16),
    Text(
    '4. Information Sharing and Disclosure',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 8),
    Text(
    'We may share your information with:\n\n'
    '• Service Providers: We may share information with third-party service providers who perform services on our behalf, such as payment processing, data analysis, email delivery, and customer support.\n\n'
    '• Business Partners: We may share information with partners with whom we offer co-branded services or products.\n\n'
    '• Legal Requirements: We may disclose your information to law enforcement or other third parties when required by law, court order, or other legal process.\n\n'
    '• Business Transfers: In connection with a business transfer such as a merger or acquisition, your information may be shared or transferred.\n\n'
    '• Affiliates: We may share your information with our subsidiaries and affiliates.\n\n'
    '• Other users: Information that you choose to display publicly may be shared with other users.',
    ),
    SizedBox(height: 16),
    Text(
    '5. Data Security',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 8),
    Text(
    'We take reasonable measures to protect your information from unauthorized access, disclosure, alteration, or destruction. However, no method of transmission over the internet or electronic storage is 100% secure, and we cannot guarantee absolute security.',
    ),
    SizedBox(height: 16),
    Text(
    '6. Data Retention',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 8),
    Text(
    'We retain your information for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law.',
    ),
    SizedBox(height: 16),
    Text(
    '7. Your Rights and Choices',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 8),
    Text(
    'You have the right to:\n\n'
    '• Access, update, or delete your personal information.\n\n'
    '• Opt out of receiving marketing communications from us.\n\n'
    '• Restrict or object to the processing of your personal information.\n\n'
    '• Request a copy of the personal information we hold about you.\n\n'
    'To exercise these rights, please contact us using the information provided at the end of this Privacy Policy.',
    ),
    SizedBox(height: 16),
    Text(
    '8. Children\'s Privacy',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 8),
    Text(
    'Our App is not intended for use by children under the age of 13, and we do not knowingly collect personal information from children under the age of 13. If we become aware that we have collected personal information from a child under the age of 13, we will take steps to delete such information.',
    ),
    SizedBox(height: 16),
    Text(
    '9. Third-Party Links and Services',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 8),
    Text(
    'Our App may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties, and we encourage you to review their privacy policies before providing them with any information.',
    ),
    SizedBox(height: 16),
    Text(
    '10. Changes to This Privacy Policy',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 8),
    Text(
    'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. We will also update the "Last Updated" date at the top of this Privacy Policy. You are advised to review this Privacy Policy periodically for any changes.',
    ),
        SizedBox(height: 16),
        Text(
          '11. Contact Us',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'If you have any questions about this Privacy Policy, please contact us at:\n\n'
              'OddsPro Bettingtips\n'
              '134-20106, molo\n' // Replace with your actual address
              'oddsprobettingtips@gmail.com\n'   // Replace with your actual email
        ),
      ],
    );
  }
}