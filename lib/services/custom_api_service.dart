// services/custom_api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../models/tip.dart';
import '../models/match.dart';

class CustomApiService {
  // Change this to your server's URL
  // For local testing use http://10.0.2.2:3000 for Android emulator
  // Use http://localhost:3000 for testing on web
  final String baseUrl = 'https://oddspro-api-p7te.onrender.com';
  final Random random = Random();

  // Fetch list of all sports
  Future<List<Map<String, dynamic>>> getSports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sports'));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load sports: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sports: $e');
      throw Exception('Error fetching sports: $e');
    }
  }

  // Fetch matches for a specific sport
  Future<List<Match>> getMatchesBySport(String sport) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/matches/$sport?regions=uk,eu&markets=h2h')
      );

      if (response.statusCode == 200) {
        final List<dynamic> matchesData = json.decode(response.body);

        // Convert API response to your Match model
        return matchesData.map((data) {
          // Extract necessary data and create Match objects
          // This will depend on your Match model structure
          return _convertToMatch(data);
        }).toList();
      } else {
        throw Exception('Failed to load matches: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching matches: $e');
      throw Exception('Error fetching matches: $e');
    }
  }

  // Get Sure Bets
  Future<List<Tip>> getSureBets() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sure-bets'));

      if (response.statusCode == 200) {
        final List<dynamic> tipsData = json.decode(response.body);

        return tipsData.map((data) => Tip.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load sure bets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sure bets: $e');
      throw Exception('Error fetching sure bets: $e');
    }
  }

  // Get Over Tips
  Future<List<Tip>> getOverTips() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/over-under-tips'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> overTipsData = data['overTips'];

        return overTipsData.map((data) => Tip.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load over tips: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching over tips: $e');
      throw Exception('Error fetching over tips: $e');
    }
  }

  // Get Under Tips
  Future<List<Tip>> getUnderTips() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/over-under-tips'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> underTipsData = data['underTips'];

        return underTipsData.map((data) => Tip.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load under tips: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching under tips: $e');
      throw Exception('Error fetching under tips: $e');
    }
  }

  // Get Free Tips
  Future<List<Tip>> getFreeTips() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/free-tips'));

      if (response.statusCode == 200) {
        final List<dynamic> tipsData = json.decode(response.body);

        return tipsData.map((data) => Tip.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load free tips: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching free tips: $e');
      throw Exception('Error fetching free tips: $e');
    }
  }

  // Get Premium Tips
  Future<List<Tip>> getPremiumTips() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/premium-tips'));

      if (response.statusCode == 200) {
        final List<dynamic> tipsData = json.decode(response.body);

        return tipsData.map((data) => Tip.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load premium tips: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching premium tips: $e');
      throw Exception('Error fetching premium tips: $e');
    }
  }

  // Helper to convert API match data to Match model
  Match _convertToMatch(Map<String, dynamic> data) {
    // Extract bookmaker odds if available
    double homeOdds = 0;
    double awayOdds = 0;
    double drawOdds = 0;

    if (data['bookmakers'] != null && data['bookmakers'].isNotEmpty) {
      final bookmaker = data['bookmakers'][0];
      if (bookmaker['markets'] != null && bookmaker['markets'].isNotEmpty) {
        final market = bookmaker['markets'].firstWhere(
                (m) => m['key'] == 'h2h',
            orElse: () => {'outcomes': []}
        );

        if (market['outcomes'] != null) {
          for (var outcome in market['outcomes']) {
            if (outcome['name'] == data['home_team']) {
              homeOdds = outcome['price']?.toDouble() ?? 0;
            } else if (outcome['name'] == data['away_team']) {
              awayOdds = outcome['price']?.toDouble() ?? 0;
            } else if (outcome['name'] == 'Draw') {
              drawOdds = outcome['price']?.toDouble() ?? 0;
            }
          }
        }
      }
    }

    // Create and return Match object
    return Match(
      id: data['id'] ?? '',
      country: data['sport_title'] ?? '',
      homeTeam: data['home_team'] ?? '',
      awayTeam: data['away_team'] ?? '',
      matchDate: DateTime.parse(data['commence_time']),
      timeEAT: _convertToEAT(data['commence_time']),
      league: data['sport_key'] ?? '',
      homeOdds: homeOdds,
      awayOdds: awayOdds,
      drawOdds: drawOdds,
    );
  }

  // Helper function to convert UTC time to EAT (East Africa Time)
  String _convertToEAT(String utcTimeString) {
    DateTime utcTime = DateTime.parse(utcTimeString);
    // EAT is UTC+3
    DateTime eatTime = utcTime.add(const Duration(hours: 3));

    // Format as "1800EAT"
    String hour = eatTime.hour.toString().padLeft(2, '0');
    String minute = eatTime.minute.toString().padLeft(2, '0');
    return '$hour${minute}EAT';
  }
}