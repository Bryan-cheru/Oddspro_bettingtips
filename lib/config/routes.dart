import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

import '../screens/free_tips_screen.dart';
import '../screens/vip_tips_screen.dart';
import '../screens/history_screen.dart';

class AppRoutes {
  // Route names
  static const String home = '/';
  static const String freeTips = '/free-tips';
  static const String vipTips = '/vip-tips';
  static const String history = '/history';

  // Route map
  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomeScreen(),
    // Add other routes as you implement them
    freeTips: (context) => const FreeTipsScreen(),
    vipTips: (context) => const VipTipsScreen(),
    history: (context) => const HistoryScreen(),
  };
}