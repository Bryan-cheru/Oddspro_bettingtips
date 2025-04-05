// services/api_services.dart
import 'package:flutter/foundation.dart';
import '../models/tip.dart';
import '../models/match.dart';
import 'odds_api_service.dart';

class ApiServices with ChangeNotifier {
  final OddsApiService _oddsApiService = OddsApiService();

  // Cache for tips and matches
  final Map<String, List<Tip>> _tipsCache = {};
  List<Match>? _matchesCache;
  DateTime? _lastFetchTime;

  // Getters for cached data
  List<Match>? get cachedMatches => _matchesCache;
  Map<String, List<Tip>> get cachedTips => _tipsCache;

  // Fetch matches
  Future<List<Match>> getMatches({bool forceRefresh = false}) async {
    // Check if we need to refresh (cache older than 30 minutes)
    final shouldRefresh = forceRefresh ||
        _matchesCache == null ||
        _lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!).inMinutes > 30;

    if (shouldRefresh) {
      try {
        final matches = await _oddsApiService.getUpcomingMatches();
        _matchesCache = matches;
        _lastFetchTime = DateTime.now();
        notifyListeners();
        return matches;
      } catch (e) {
        print('Error fetching matches: $e');
        // Return cached data if available, otherwise rethrow
        if (_matchesCache != null) {
          return _matchesCache!;
        }
        rethrow;
      }
    } else {
      return _matchesCache!;
    }
  }

  // Fetch tips by category
  Future<List<Tip>> getTipsByCategory(String category, {bool forceRefresh = false}) async {
    // Check if we need to refresh
    final shouldRefresh = forceRefresh ||
        !_tipsCache.containsKey(category) ||
        _lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!).inMinutes > 30;

    if (shouldRefresh) {
      try {
        final tips = await _oddsApiService.getTipsByCategory(category);
        _tipsCache[category] = tips;
        _lastFetchTime = DateTime.now();
        notifyListeners();
        return tips;
      } catch (e) {
        print('Error fetching tips for category $category: $e');
        // Return cached data if available, otherwise rethrow
        if (_tipsCache.containsKey(category)) {
          return _tipsCache[category]!;
        }
        rethrow;
      }
    } else {
      return _tipsCache[category]!;
    }
  }

  // Get free tips
  Future<List<Tip>> getFreeTips({bool forceRefresh = false}) async {
    return getTipsByCategory('free tips', forceRefresh: forceRefresh);
  }

  // Get VIP/premium tips
  Future<List<Tip>> getPremiumTips({bool forceRefresh = false}) async {
    return getTipsByCategory('premium tips', forceRefresh: forceRefresh);
  }

  // Get sure bets
  Future<List<Tip>> getSureBets({bool forceRefresh = false}) async {
    return getTipsByCategory('sure bets', forceRefresh: forceRefresh);
  }

  // Get over tips
  Future<List<Tip>> getOverTips({bool forceRefresh = false}) async {
    return getTipsByCategory('over tips', forceRefresh: forceRefresh);
  }

  // Get under tips
  Future<List<Tip>> getUnderTips({bool forceRefresh = false}) async {
    return getTipsByCategory('under tips', forceRefresh: forceRefresh);
  }

  // Get daily 2+ odds
  Future<List<Tip>> getDailyHighOdds({bool forceRefresh = false}) async {
    return getTipsByCategory('daily 2+ odds', forceRefresh: forceRefresh);
  }

  // Get super draws
  Future<List<Tip>> getSuperDraws({bool forceRefresh = false}) async {
    return getTipsByCategory('super draws', forceRefresh: forceRefresh);
  }

  // Get BTTS tips
  Future<List<Tip>> getBTTS({bool forceRefresh = false}) async {
    return getTipsByCategory('gg tips', forceRefresh: forceRefresh);
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    try {
      await getMatches(forceRefresh: true);

      // Refresh all categories
      final categories = [
        'free tips',
        'premium tips',
        'sure bets',
        'over tips',
        'under tips',
        'daily 2+ odds',
        'super draws',
        'gg tips'
      ];

      for (var category in categories) {
        await getTipsByCategory(category, forceRefresh: true);
      }

      notifyListeners();
    } catch (e) {
      print('Error refreshing all data: $e');
      rethrow;
    }
  }

  // Clear cache
  void clearCache() {
    _matchesCache = null;
    _tipsCache.clear();
    _lastFetchTime = null;
    notifyListeners();
  }
}