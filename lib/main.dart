// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/firebase_service.dart';
import 'services/api_services.dart';
import 'services/data_coordinator_service.dart';
// Removed Stripe import for now

Future<void> setupFirestore() async {
  final firebaseService = FirebaseService();

  // This will check if data exists and only populate if empty
  await firebaseService.populateInitialData();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    // Set up initial data
    await setupFirestore();
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add our standalone API services provider
        ChangeNotifierProvider(create: (_) => ApiServices()),

        // Add Data Coordinator service that connects API and Firebase
        ChangeNotifierProxyProvider<ApiServices, DataCoordinatorService>(
          create: (context) => DataCoordinatorService(
            Provider.of<ApiServices>(context, listen: false),
          ),
          update: (context, apiServices, previous) =>
              DataCoordinatorService(apiServices),
        ),
      ],
      child: MaterialApp(
        title: 'ODDSPRO BETTINGTIPS',
        theme: AppTheme.lightTheme,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.home,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}