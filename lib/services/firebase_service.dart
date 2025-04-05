import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/tip.dart';
import '../models/match.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final bool _useMockData =
      true; // Change to false when Firestore is fully populated

  // =====================
  // API INTEGRATION METHODS
  // =====================

  // Fetch and store matches from Odds API
  Future<List<Match>> fetchAndStoreMatches() async {
    final OddsApiService oddsApiService = OddsApiService();

    try {
      // Get matches from API
      List<Match> matches = await oddsApiService.getUpcomingMatches();

      // Store matches in Firestore
      for (var match in matches) {
        await _firestore
            .collection('matches')
            .doc(match.id)
            .set(match.toJson());
      }

      // Optionally, create tips automatically
      for (var match in matches) {
        // Only create tips for high confidence predictions
        if (_shouldCreateTip(match)) {
          await _createTipFromMatch(match);
        }
      }

      return matches;
    } catch (e) {
      print('Error in fetchAndStoreMatches: $e');
      return [];
    }
  }

  // Determine if we should create a tip for this match
  bool _shouldCreateTip(Match match) {
    // This is where you'd implement your prediction logic
    // For example, you might only create tips when odds are very favorable

    // Sample logic: create tip when home odds are less than 1.5 (strong favorite)
    if (match.homeOdds > 0 && match.homeOdds < 1.5) {
      return true;
    }

    // Sample logic: create tip for likely draws
    if (match.drawOdds > 0 &&
        match.drawOdds < 3.0 &&
        (match.homeOdds - match.awayOdds).abs() < 0.5) {
      return true;
    }

    // Sample logic: create tip for strong away team
    if (match.awayOdds > 0 && match.awayOdds < 2.0) {
      return true;
    }

    return false;
  }

  // Create a tip from a match
  Future<void> _createTipFromMatch(Match match) async {
    // Determine the prediction
    String prediction;
    double odds;

    if (match.homeOdds > 0 &&
        match.homeOdds < match.awayOdds &&
        match.homeOdds < match.drawOdds) {
      prediction = 'Home win';
      odds = match.homeOdds;
    } else if (match.awayOdds > 0 &&
        match.awayOdds < match.homeOdds &&
        match.awayOdds < match.drawOdds) {
      prediction = 'Away win';
      odds = match.awayOdds;
    } else if (match.drawOdds > 0) {
      prediction = 'Draw';
      odds = match.drawOdds;
    } else {
      // Can't make a prediction
      return;
    }

    // Determine if this should be a premium tip
    bool isPremium = odds < 2.0; // Make very strong predictions premium

    // Choose category
    String category;
    if (prediction == 'Draw') {
      category = 'Super Draws';
    } else if (odds < 1.5) {
      category = 'Sure Bets';
    } else if (match.homeTeam.contains('Manchester') ||
        match.awayTeam.contains('Manchester')) {
      category = 'Premium Tips'; // Just an example for specific teams
    } else {
      category = 'Daily 2+ Odds';
    }

    // Check if we already have a tip for this match
    QuerySnapshot existing = await _firestore
        .collection('tips')
        .where('matchId', isEqualTo: match.id)
        .get();

    if (existing.docs.isEmpty) {
      // Add the tip to Firestore
      await _firestore.collection('tips').add({
        'matchId': match.id,
        'prediction': prediction,
        'odds': odds,
        'result': 'pending',
        'isPremium': isPremium,
        'category': category,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Update sports results for completed matches
  Future<List<Match>> getPendingResultMatches() async {
    // Get all matches that should have completed by now
    final now = DateTime.now();

    QuerySnapshot matchesSnapshot = await _firestore
        .collection('matches')
        .where('status', isEqualTo: 'scheduled')
        .where('matchDate',
            isLessThan: now.subtract(
                const Duration(hours: 2))) // Match should have ended 2 hours ago
        .get();

    return matchesSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Match.fromJson(data);
    }).toList();
  }

  // =====================
  // CORE FIRESTORE METHODS
  // =====================

  // Get free tips
  Future<List<Tip>> getFreeTips() async {
    if (_useMockData) {
      return _getMockFreeTips();
    }

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('tips')
          .where('isPremium', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return await _processTipSnapshots(querySnapshot);
    } catch (e) {
      print('Error getting free tips: $e');
      return _getMockFreeTips();
    }
  }

  // Get VIP tips
  Future<List<Tip>> getVipTips() async {
    if (_useMockData) {
      return _getMockVipTips();
    }

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('tips')
          .where('isPremium', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return await _processTipSnapshots(querySnapshot);
    } catch (e) {
      print('Error getting VIP tips: $e');
      return _getMockVipTips();
    }
  }

  // Get history tips
  Future<List<Tip>> getHistoryTips() async {
    if (_useMockData) {
      return _getMockHistoryTips();
    }

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('tips')
          .where('result', whereIn: ['win', 'loss'])
          .orderBy('matchDate', descending: true)
          .get();

      return await _processTipSnapshots(querySnapshot);
    } catch (e) {
      print('Error getting history tips: $e');
      return _getMockHistoryTips();
    }
  }

  // Get tips by category
  Future<List<Tip>> getTipsByCategory(String category) async {
    try {
      QuerySnapshot tipsSnapshot = await _firestore
          .collection('tips')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return await _processTipSnapshots(tipsSnapshot);
    } catch (e) {
      print('Error getting tips by category: $e');
      return []; // Return empty list on error
    }
  }

  // Helper method to process tip snapshots and fetch associated match data
  Future<List<Tip>> _processTipSnapshots(QuerySnapshot tipsSnapshot) async {
    List<Tip> tips = [];

    for (var doc in tipsSnapshot.docs) {
      Map<String, dynamic> tipData = doc.data() as Map<String, dynamic>;
      tipData['id'] = doc.id;

      // Get the match data if it's referenced by ID
      if (tipData.containsKey('matchId')) {
        String matchId = tipData['matchId'];
        DocumentSnapshot matchDoc =
            await _firestore.collection('matches').doc(matchId).get();

        if (matchDoc.exists) {
          Map<String, dynamic> matchData =
              matchDoc.data() as Map<String, dynamic>;
          matchData['id'] = matchDoc.id;

          // Create a tip with the match data
          tips.add(Tip.fromJson({
            ...tipData,
            'match': matchData,
          }));
        }
      } else if (tipData.containsKey('match')) {
        // If match data is embedded in the tip document
        tips.add(Tip.fromJson(tipData));
      }
    }

    return tips;
  }

  // Add a new tip
  Future<bool> addTip(Tip tip) async {
    try {
      await _firestore.collection('tips').add(tip.toJson());
      return true;
    } catch (e) {
      print('Error adding tip: $e');
      return false;
    }
  }

  // Update a tip
  Future<bool> updateTip(Tip tip) async {
    try {
      await _firestore.collection('tips').doc(tip.id).update(tip.toJson());
      return true;
    } catch (e) {
      print('Error updating tip: $e');
      return false;
    }
  }

  // Delete a tip
  Future<bool> deleteTip(String tipId) async {
    try {
      await _firestore.collection('tips').doc(tipId).delete();
      return true;
    } catch (e) {
      print('Error deleting tip: $e');
      return false;
    }
  }

  // Update a match result
  Future<bool> updateMatchResult(
      String matchId, int homeScore, int awayScore) async {
    try {
      await _firestore.collection('matches').doc(matchId).update({
        'status': 'completed',
        'homeScore': homeScore,
        'awayScore': awayScore,
      });

      // Now update all tips related to this match
      QuerySnapshot tipsSnapshot = await _firestore
          .collection('tips')
          .where('matchId', isEqualTo: matchId)
          .get();

      for (var doc in tipsSnapshot.docs) {
        Map<String, dynamic> tipData = doc.data() as Map<String, dynamic>;
        String prediction = tipData['prediction'];

        // Determine if prediction was correct based on scores and prediction type
        bool isCorrect = _isPredictionCorrect(prediction, homeScore, awayScore);

        await _firestore.collection('tips').doc(doc.id).update({
          'result': isCorrect ? 'win' : 'loss',
          'score': '$homeScore:$awayScore',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      print('Error updating match result: $e');
      return false;
    }
  }

  // Helper to determine if a prediction was correct
  bool _isPredictionCorrect(String prediction, int homeScore, int awayScore) {
    prediction = prediction.toLowerCase();

    if (prediction == 'home win') {
      return homeScore > awayScore;
    } else if (prediction == 'away win') {
      return homeScore < awayScore;
    } else if (prediction == 'draw') {
      return homeScore == awayScore;
    } else if (prediction == 'btts' || prediction == 'gg') {
      return homeScore > 0 && awayScore > 0;
    } else if (prediction.contains('over')) {
      // Extract the number from "Over X.5"
      RegExp regExp = RegExp(r'over (\d+\.?\d*)');
      var match = regExp.firstMatch(prediction);
      if (match != null) {
        double threshold = double.parse(match.group(1)!);
        return (homeScore + awayScore) > threshold;
      }
    } else if (prediction.contains('under')) {
      // Extract the number from "Under X.5"
      RegExp regExp = RegExp(r'under (\d+\.?\d*)');
      var match = regExp.firstMatch(prediction);
      if (match != null) {
        double threshold = double.parse(match.group(1)!);
        return (homeScore + awayScore) < threshold;
      }
    }

    return false; // Default if prediction type is not recognized
  }

  // Function to populate initial data in Firestore
  Future<void> populateInitialData() async {
    try {
      final CollectionReference tips = _firestore.collection('tips');

      // First, check if there's already data to avoid duplicates
      QuerySnapshot existingData = await tips.limit(1).get();
      if (existingData.docs.isNotEmpty) {
        print('Firestore already has data, skipping population');
        return;
      }

      print('Starting to populate Firestore with initial data');

      // Free tips
      final List<Map<String, dynamic>> freeTips = [
        {
          'match': {
            'id': 'm1',
            'country': 'Brazil',
            'homeTeam': 'Piauí',
            'awayTeam': 'River-PI',
            'matchDate': Timestamp.fromDate(DateTime(2025, 3, 1)),
            'timeEAT': '2200EAT',
          },
          'prediction': 'Home win',
          'odds': 2.85,
          'result': 'win',
          'score': '2:0',
          'isPremium': false,
          'category': 'Sure Bets',
        },
        {
          'match': {
            'id': 'm2',
            'country': 'England',
            'homeTeam': 'Bournemouth',
            'awayTeam': 'Wolves',
            'matchDate': Timestamp.fromDate(DateTime(2025, 3, 1)),
            'timeEAT': '1800EAT',
          },
          'prediction': 'Home win',
          'odds': 1.87,
          'result': 'loss',
          'score': '1:1',
          'isPremium': false,
          'category': 'Sure Bets',
        },
        {
          'match': {
            'id': 'm3',
            'country': 'Spain',
            'homeTeam': 'Barcelona',
            'awayTeam': 'Real Madrid',
            'matchDate': Timestamp.fromDate(DateTime(2025, 3, 2)),
            'timeEAT': '2100EAT',
          },
          'prediction': 'Over 2.5',
          'odds': 1.95,
          'result': 'pending',
          'isPremium': false,
          'category': 'Over Tips',
        },
      ];

      // VIP tips
      final List<Map<String, dynamic>> vipTips = [
        {
          'match': {
            'id': 'm4',
            'country': 'Italy',
            'homeTeam': 'Juventus',
            'awayTeam': 'Inter',
            'matchDate': Timestamp.fromDate(DateTime(2025, 3, 2)),
            'timeEAT': '2045EAT',
          },
          'prediction': 'BTTS',
          'odds': 1.75,
          'result': 'pending',
          'isPremium': true,
          'category': 'Daily 2+ Odds',
        },
        {
          'match': {
            'id': 'm5',
            'country': 'Germany',
            'homeTeam': 'Bayern Munich',
            'awayTeam': 'Dortmund',
            'matchDate': Timestamp.fromDate(DateTime(2025, 3, 2)),
            'timeEAT': '1930EAT',
          },
          'prediction': 'Home & Over 2.5',
          'odds': 2.10,
          'result': 'pending',
          'isPremium': true,
          'category': 'Daily 2+ Odds',
        },
      ];

      // History tips
      final List<Map<String, dynamic>> historyTips = [
        {
          'match': {
            'id': 'm6',
            'country': 'England',
            'homeTeam': 'Arsenal',
            'awayTeam': 'Chelsea',
            'matchDate': Timestamp.fromDate(DateTime(2025, 2, 28)),
            'timeEAT': '2000EAT',
          },
          'prediction': 'Draw',
          'odds': 3.40,
          'result': 'win',
          'score': '1:1',
          'isPremium': false,
          'category': 'Super Draws',
        },
        {
          'match': {
            'id': 'm7',
            'country': 'Italy',
            'homeTeam': 'AC Milan',
            'awayTeam': 'Napoli',
            'matchDate': Timestamp.fromDate(DateTime(2025, 2, 27)),
            'timeEAT': '2045EAT',
          },
          'prediction': 'BTTS',
          'odds': 1.85,
          'result': 'win',
          'score': '2:1',
          'isPremium': true,
          'category': 'GG Tips',
        },
        {
          'match': {
            'id': 'm8',
            'country': 'France',
            'homeTeam': 'PSG',
            'awayTeam': 'Lyon',
            'matchDate': Timestamp.fromDate(DateTime(2025, 2, 26)),
            'timeEAT': '2100EAT',
          },
          'prediction': 'Away win',
          'odds': 4.50,
          'result': 'loss',
          'score': '3:1',
          'isPremium': true,
          'category': 'Sure Bets',
        },
      ];

      // Combine all tips
      final allTips = [...freeTips, ...vipTips, ...historyTips];

      // Add each tip to Firestore
      for (final tip in allTips) {
        await tips.add(tip);
        print(
            'Added tip: ${tip['match']['homeTeam']} vs ${tip['match']['awayTeam']}');
      }

      print('Successfully populated Firestore with ${allTips.length} tips');
    } catch (e) {
      print('Error populating Firestore: $e');
    }
  }

  // Mock data methods for development
  List<Tip> _getMockFreeTips() {
    return [
      Tip(
        id: '1',
        match: Match(
          id: 'm1',
          country: 'Brazil',
          homeTeam: 'Piauí',
          awayTeam: 'River-PI',
          matchDate: DateTime(2025, 3, 1),
          timeEAT: '2200EAT',
        ),
        prediction: 'Home win',
        odds: 2.85,
        result: TipResult.win,
        score: '2:0',
        category: 'Sure Bets',
      ),
      Tip(
        id: '2',
        match: Match(
          id: 'm2',
          country: 'England',
          homeTeam: 'Bournemouth',
          awayTeam: 'Wolves',
          matchDate: DateTime(2025, 3, 1),
          timeEAT: '1800EAT',
        ),
        prediction: 'Home win',
        odds: 1.87,
        result: TipResult.loss,
        score: '1:1',
        category: 'Sure Bets',
      ),
      Tip(
        id: '3',
        match: Match(
          id: 'm3',
          country: 'Spain',
          homeTeam: 'Barcelona',
          awayTeam: 'Real Madrid',
          matchDate: DateTime(2025, 3, 2),
          timeEAT: '2100EAT',
        ),
        prediction: 'Over 2.5',
        odds: 1.95,
        result: TipResult.pending,
        category: 'Over Tips',
      ),
    ];
  }

  List<Tip> _getMockVipTips() {
    return [
      Tip(
        id: '4',
        match: Match(
          id: 'm4',
          country: 'Italy',
          homeTeam: 'Juventus',
          awayTeam: 'Inter',
          matchDate: DateTime(2025, 3, 2),
          timeEAT: '2045EAT',
        ),
        prediction: 'BTTS',
        odds: 1.75,
        result: TipResult.pending,
        isPremium: true,
        category: 'Daily 2+ Odds',
      ),
      Tip(
        id: '5',
        match: Match(
          id: 'm5',
          country: 'Germany',
          homeTeam: 'Bayern Munich',
          awayTeam: 'Dortmund',
          matchDate: DateTime(2025, 3, 2),
          timeEAT: '1930EAT',
        ),
        prediction: 'Home & Over 2.5',
        odds: 2.10,
        result: TipResult.pending,
        isPremium: true,
        category: 'Daily 2+ Odds',
      ),
    ];
  }

  List<Tip> _getMockHistoryTips() {
    return [
      Tip(
        id: '6',
        match: Match(
          id: 'm6',
          country: 'England',
          homeTeam: 'Arsenal',
          awayTeam: 'Chelsea',
          matchDate: DateTime(2025, 2, 28),
          timeEAT: '2000EAT',
        ),
        prediction: 'Draw',
        odds: 3.40,
        result: TipResult.win,
        score: '1:1',
        category: 'Super Draws',
      ),
      Tip(
        id: '7',
        match: Match(
          id: 'm7',
          country: 'Italy',
          homeTeam: 'AC Milan',
          awayTeam: 'Napoli',
          matchDate: DateTime(2025, 2, 27),
          timeEAT: '2045EAT',
        ),
        prediction: 'BTTS',
        odds: 1.85,
        result: TipResult.win,
        score: '2:1',
        isPremium: true,
        category: 'GG Tips',
      ),
      Tip(
        id: '8',
        match: Match(
          id: 'm8',
          country: 'France',
          homeTeam: 'PSG',
          awayTeam: 'Lyon',
          matchDate: DateTime(2025, 2, 26),
          timeEAT: '2100EAT',
        ),
        prediction: 'Away win',
        odds: 4.50,
        result: TipResult.loss,
        score: '3:1',
        isPremium: true,
        category: 'Sure Bets',
      ),
    ];
  }
}

// Odds API Service
class OddsApiService {
  final String apiKey = 'a29969d05d3bbafd1338e7191c07a708';
  final String baseUrl = 'https://api.the-odds-api.com/v4';

  // Fetch upcoming matches
  Future<List<Match>> getUpcomingMatches(
      {String sport = 'soccer',
      String regions = 'uk,eu',
      String markets = 'h2h'}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/sports/$sport/odds/?apiKey=$apiKey&regions=$regions&markets=$markets'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return _convertToMatches(data);
      } else {
        throw Exception('Failed to load matches: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching upcoming matches: $e');
      throw Exception('Error fetching upcoming matches: $e');
    }
  }

  // Fetch sports
  Future<List<Map<String, dynamic>>> getSports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sports/?apiKey=$apiKey'),
      );

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

  // Convert API response to Match objects
  List<Match> _convertToMatches(List<dynamic> data) {
    List<Match> matches = [];

    for (var matchData in data) {
      // Extract country/league from sport_key
      String country = matchData['sport_title'] ?? '';
      if (country.contains('- ')) {
        country = country.split('- ')[0].trim();
      }

      // Extract team names
      String homeTeam = '';
      String awayTeam = '';
      if (matchData['home_team'] != null && matchData['away_team'] != null) {
        homeTeam = matchData['home_team'];
        awayTeam = matchData['away_team'];
      }

      // Calculate odds
      double homeOdds = 0;
      double awayOdds = 0;
      double drawOdds = 0;

      if (matchData['bookmakers'] != null &&
          matchData['bookmakers'].isNotEmpty) {
        // Get odds from first bookmaker
        var bookmaker = matchData['bookmakers'][0];
        if (bookmaker['markets'] != null && bookmaker['markets'].isNotEmpty) {
          var market = bookmaker['markets'][0]; // Usually h2h
          if (market['outcomes'] != null) {
            for (var outcome in market['outcomes']) {
              if (outcome['name'] == homeTeam) {
                homeOdds = outcome['price']?.toDouble() ?? 0;
              } else if (outcome['name'] == awayTeam) {
                awayOdds = outcome['price']?.toDouble() ?? 0;
              } else if (outcome['name'] == 'Draw') {
                drawOdds = outcome['price']?.toDouble() ?? 0;
              }
            }
          }
        }
      }

      // Create Match object
      Match match = Match(
        id: matchData['id'] ?? '',
        country: country,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        matchDate: DateTime.parse(matchData['commence_time']),
        timeEAT: _convertToEAT(matchData['commence_time']),
        league: matchData['sport_key'] ?? '',
        homeOdds: homeOdds,
        awayOdds: awayOdds,
        drawOdds: drawOdds,
      );

      matches.add(match);
    }

    return matches;
  }

  // Convert UTC time to EAT (East Africa Time)
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
