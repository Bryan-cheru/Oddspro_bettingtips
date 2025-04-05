// services/data_coordinator_service.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tip.dart';
import '../models/match.dart';
import 'firebase_service.dart';
import 'api_services.dart';

class DataCoordinatorService with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final ApiServices _apiServices;
  // Create our own Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Settings
  bool _useDirectApi = true; // Set to true to use API directly, false to use Firebase
  bool _syncToFirebase = false; // Set to false for now to avoid Firebase issues

  DataCoordinatorService(this._apiServices);

  // Getters for settings
  bool get useDirectApi => _useDirectApi;
  bool get syncToFirebase => _syncToFirebase;

  // Setters for settings
  set useDirectApi(bool value) {
    if (_useDirectApi != value) {
      _useDirectApi = value;
      notifyListeners();
    }
  }

  set syncToFirebase(bool value) {
    if (_syncToFirebase != value) {
      _syncToFirebase = value;
      notifyListeners();
    }
  }

  // Get free tips - choose appropriate source based on settings
  Future<List<Tip>> getFreeTips() async {
    if (_useDirectApi) {
      // Get tips directly from API
      final tips = await _apiServices.getFreeTips();

      // Optionally sync to Firebase - disabled for now
      if (_syncToFirebase) {
        _syncTipsToFirebase(tips);
      }

      return tips;
    } else {
      // Get tips from Firebase
      return _firebaseService.getFreeTips();
    }
  }


  // Get VIP tips
  Future<List<Tip>> getVipTips() async {
    if (_useDirectApi) {
      // Get tips directly from API
      final tips = await _apiServices.getPremiumTips();

      // Optionally sync to Firebase
      if (_syncToFirebase) {
        _syncTipsToFirebase(tips);
      }

      return tips;
    } else {
      // Get tips from Firebase
      return _firebaseService.getVipTips();
    }
  }

  // Get history tips
  Future<List<Tip>> getHistoryTips() async {
    // History should probably come from Firebase since the API only has current data
    if (!_useDirectApi) {
      return _firebaseService.getHistoryTips();
    }

    // Use API data and simulate history for demo purposes
    final allTips = await _apiServices.getFreeTips();
    final vipTips = await _apiServices.getPremiumTips();

    // Combine tips
    List<Tip> combinedTips = [...allTips, ...vipTips];

    // Take the first 10 tips and make them look like history
    List<Tip> historyTips = combinedTips.take(10).map((tip) {
      // Create a random result (win or loss)
      final bool isWin = DateTime.now().millisecondsSinceEpoch % 2 == 0;
      final result = isWin ? TipResult.win : TipResult.loss;

      // Generate a random score
      final homeScore = (DateTime.now().millisecond % 4);
      final awayScore = (DateTime.now().microsecond % 3);

      // Return a modified tip with result
      return Tip(
        id: tip.id,
        match: tip.match,
        prediction: tip.prediction,
        odds: tip.odds,
        result: result,
        score: '$homeScore:$awayScore',
        isPremium: tip.isPremium,
        category: tip.category,
      );
    }).toList();

    return historyTips;
  }

  // Get tips by category
  Future<List<Tip>> getTipsByCategory(String category) async {
    if (_useDirectApi) {
      switch (category.toLowerCase()) {
        case 'sure bets':
          return _apiServices.getSureBets();
        case 'over tips':
          return _apiServices.getOverTips();
        case 'under tips':
          return _apiServices.getUnderTips();
        case 'daily 2+ odds':
          return _apiServices.getDailyHighOdds();
        case 'super draws':
          return _apiServices.getSuperDraws();
        case 'gg tips':
          return _apiServices.getBTTS();
        default:
          return _apiServices.getFreeTips();
      }
    } else {
      return _firebaseService.getTipsByCategory(category);
    }
  }

  // Fetch and sync matches - uses your existing FirebaseService.fetchAndStoreMatches
  Future<List<Match>> fetchAndSyncMatches() async {
    try {
      if (_useDirectApi) {
        // Get matches from API
        final matches = await _apiServices.getMatches(forceRefresh: true);

        // Sync to Firebase if enabled
        if (_syncToFirebase) {
          // Use your existing firebase service method which already does this well
          await _firebaseService.fetchAndStoreMatches();
        }

        return matches;
      } else {
        // Use your existing method that already fetches and stores matches
        return _firebaseService.fetchAndStoreMatches();
      }
    } catch (e) {
      print('Error in fetchAndSyncMatches: $e');
      return [];
    }
  }

  // Get pending matches that need results
  Future<List<Match>> getPendingResultMatches() async {
    return _firebaseService.getPendingResultMatches();
  }

  // Add new tip
  Future<bool> addTip(Tip tip) async {
    return _firebaseService.addTip(tip);
  }

  // Update tip
  Future<bool> updateTip(Tip tip) async {
    return _firebaseService.updateTip(tip);
  }

  // Delete tip
  Future<bool> deleteTip(String tipId) async {
    return _firebaseService.deleteTip(tipId);
  }

  // Update match result
  Future<bool> updateMatchResult(String matchId, int homeScore, int awayScore) async {
    return _firebaseService.updateMatchResult(matchId, homeScore, awayScore);
  }

  // Helper method to sync tips to Firebase - uses our own Firestore instance
  Future<void> _syncTipsToFirebase(List<Tip> tips) async {
    try {
      for (var tip in tips) {
        // Check if we already have this tip in Firebase
        var existingTips = await _firestore
            .collection('tips')
            .where('matchId', isEqualTo: tip.match.id)
            .where('prediction', isEqualTo: tip.prediction)
            .get();

        if (existingTips.docs.isEmpty) {
          // Add the match first
          await _firestore
              .collection('matches')
              .doc(tip.match.id)
              .set({
            'id': tip.match.id,
            'country': tip.match.country,
            'homeTeam': tip.match.homeTeam,
            'awayTeam': tip.match.awayTeam,
            'matchDate': tip.match.matchDate.toIso8601String(),
            'timeEAT': tip.match.timeEAT,
            'league': tip.match.league,
            'homeOdds': tip.match.homeOdds,
            'awayOdds': tip.match.awayOdds,
            'drawOdds': tip.match.drawOdds,
            'status': tip.match.status,
          });

          // Then add the tip
          await _firestore
              .collection('tips')
              .add({
            'matchId': tip.match.id,
            'prediction': tip.prediction,
            'odds': tip.odds,
            'result': tip.result.name,
            'score': tip.score,
            'isPremium': tip.isPremium,
            'category': tip.category,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('Error syncing tips to Firebase: $e');
    }
  }

  // Push all API data to Firebase for backup/persistence
  Future<void> backupAllDataToFirebase() async {
    try {
      // Get all data from API
      final freeTips = await _apiServices.getFreeTips();
      final vipTips = await _apiServices.getPremiumTips();
      final matches = await _apiServices.getMatches(forceRefresh: true);

      // Sync all tips
      await _syncTipsToFirebase([...freeTips, ...vipTips]);

      // Make sure all matches are in Firebase
      for (var match in matches) {
        await _firestore
            .collection('matches')
            .doc(match.id)
            .set({
          'id': match.id,
          'country': match.country,
          'homeTeam': match.homeTeam,
          'awayTeam': match.awayTeam,
          'matchDate': match.matchDate.toIso8601String(),
          'timeEAT': match.timeEAT,
          'league': match.league,
          'homeOdds': match.homeOdds,
          'awayOdds': match.awayOdds,
          'drawOdds': match.drawOdds,
          'status': match.status,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error backing up data to Firebase: $e');
    }
  }
}