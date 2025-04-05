// services/odds_api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../models/match.dart';
import '../models/tip.dart';

class OddsApiService {
  final String apiKey = 'a29969d05d3bbafd1338e7191c07a708';
  final String baseUrl = 'https://api.the-odds-api.com/v4';
  final Random random = Random();

  // Fetch upcoming matches
  Future<List<Match>> getUpcomingMatches({
    String sport = 'soccer',
    String regions = 'uk,eu',
    String markets = 'h2h,totals',
    int daysFrom = 0,
    int daysTo = 3,
  }) async {
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

  // Get Sure Bets - matches with high probability of a specific outcome
  Future<List<Tip>> getSureBets() async {
    try {
      final matches = await getUpcomingMatches(markets: 'h2h');

      // Filter matches for sure bets (high probability bets)
      final List<Tip> sureBets = [];

      for (var match in matches) {
        // A sure bet can be a home win, away win, or draw based on odds comparison
        String prediction = '';
        double odds = 0.0;

        // Logic to determine the most likely outcome
        if (match.homeOdds < match.awayOdds && match.homeOdds < match.drawOdds) {
          prediction = 'Home win';
          odds = match.homeOdds;
        } else if (match.awayOdds < match.homeOdds && match.awayOdds < match.drawOdds) {
          prediction = 'Away win';
          odds = match.awayOdds;
        } else {
          prediction = 'Draw';
          odds = match.drawOdds;
        }

        // Only include as a sure bet if odds are below a threshold (more likely)
        if (odds > 0 && odds < 2.0) {
          sureBets.add(Tip(
            id: 'tip_${match.id}',
            match: match,
            prediction: prediction,
            odds: odds,
            category: 'Sure Bets',
            isPremium: odds < 1.5,  // Very low odds predictions could be premium
          ));
        }
      }

      return sureBets;
    } catch (e) {
      print('Error getting sure bets: $e');
      throw Exception('Error getting sure bets: $e');
    }
  }

  // Get Over Tips - matches likely to have goals over a threshold
  Future<List<Tip>> getOverTips() async {
    try {
      // Need to include totals market for over/under predictions
      final matches = await getUpcomingMatches(markets: 'h2h,totals');

      // Filter matches for over tips
      final List<Tip> overTips = [];

      for (var match in matches) {
        // For demo purposes, we'll create over 2.5 goals tips
        // In real implementation, you'd need to parse the totals market from the API

        // Create a tip with over prediction
        // This is simplified; ideally you'd parse actual over/under odds from API
        if (random.nextDouble() < 0.7) {  // 70% of matches to have over tips (for demo)
          double overOdds = 1.5 + random.nextDouble();  // Random odds between 1.5 and 2.5

          overTips.add(Tip(
            id: 'tip_over_${match.id}',
            match: match,
            prediction: 'Over 2.5',
            odds: overOdds,
            category: 'Over Tips',
            isPremium: random.nextBool(),
          ));
        }
      }

      return overTips;
    } catch (e) {
      print('Error getting over tips: $e');
      throw Exception('Error getting over tips: $e');
    }
  }

  // Get Under Tips - matches likely to have goals under a threshold
  Future<List<Tip>> getUnderTips() async {
    try {
      // Need to include totals market for over/under predictions
      final matches = await getUpcomingMatches(markets: 'h2h,totals');

      // Filter matches for under tips
      final List<Tip> underTips = [];

      for (var match in matches) {
        // For demo purposes, we'll create under 2.5 goals tips
        // In real implementation, you'd need to parse the totals market from the API

        // Create a tip with under prediction
        if (random.nextDouble() < 0.6) {  // 60% of matches to have under tips (for demo)
          double underOdds = 1.6 + random.nextDouble();  // Random odds between 1.6 and 2.6

          underTips.add(Tip(
            id: 'tip_under_${match.id}',
            match: match,
            prediction: 'Under 2.5',
            odds: underOdds,
            category: 'Under Tips',
            isPremium: random.nextBool(),
          ));
        }
      }

      return underTips;
    } catch (e) {
      print('Error getting under tips: $e');
      throw Exception('Error getting under tips: $e');
    }
  }

  // Get Daily 2+ Odds - tips with odds greater than 2.0
  Future<List<Tip>> getDailyHighOdds() async {
    try {
      final matches = await getUpcomingMatches();

      // Filter matches for high odds tips
      final List<Tip> highOddsTips = [];

      for (var match in matches) {
        // Look for the highest odds in each match
        String prediction = '';
        double highestOdds = 0.0;

        if (match.homeOdds > 2.0 && match.homeOdds > highestOdds) {
          prediction = 'Home win';
          highestOdds = match.homeOdds;
        }

        if (match.awayOdds > 2.0 && match.awayOdds > highestOdds) {
          prediction = 'Away win';
          highestOdds = match.awayOdds;
        }

        if (match.drawOdds > 2.0 && match.drawOdds > highestOdds) {
          prediction = 'Draw';
          highestOdds = match.drawOdds;
        }

        if (highestOdds > 2.0) {
          highOddsTips.add(Tip(
            id: 'tip_high_${match.id}',
            match: match,
            prediction: prediction,
            odds: highestOdds,
            category: 'Daily 2+ Odds',
            isPremium: highestOdds > 3.0,  // Very high odds predictions could be premium
          ));
        }
      }

      return highOddsTips;
    } catch (e) {
      print('Error getting high odds tips: $e');
      throw Exception('Error getting high odds tips: $e');
    }
  }

  // Get Super Draws - matches with high probability of a draw
  Future<List<Tip>> getSuperDraws() async {
    try {
      final matches = await getUpcomingMatches();

      // Filter matches for super draws
      final List<Tip> superDraws = [];

      for (var match in matches) {
        // A super draw has relatively low draw odds (higher probability)
        // And teams that are closely matched (similar home/away odds)

        // Check if draw odds are reasonable and teams seem evenly matched
        if (match.drawOdds > 0 && match.drawOdds < 3.5 &&
            (match.homeOdds / match.awayOdds).abs() < 1.5) {

          superDraws.add(Tip(
            id: 'tip_draw_${match.id}',
            match: match,
            prediction: 'Draw',
            odds: match.drawOdds,
            category: 'Super Draws',
            isPremium: match.drawOdds < 3.0,  // Lower odds draws could be premium
          ));
        }
      }

      return superDraws;
    } catch (e) {
      print('Error getting super draws: $e');
      throw Exception('Error getting super draws: $e');
    }
  }

  // Get Both Teams To Score (BTTS) tips
  Future<List<Tip>> getBTTS() async {
    try {
      final matches = await getUpcomingMatches(markets: 'h2h');

      // For BTTS we'd normally need a specific market from the API
      // For demonstration, we'll use some heuristics

      final List<Tip> bttsTips = [];

      for (var match in matches) {
        // Teams with similar attacking strength might have higher BTTS probability
        // This is just for demonstration - real implementation would use actual odds
        if (random.nextDouble() < 0.5) {  // 50% of matches to have BTTS tips (for demo)
          double bttsOdds = 1.5 + random.nextDouble();  // Random odds between 1.5 and 2.5

          bttsTips.add(Tip(
            id: 'tip_btts_${match.id}',
            match: match,
            prediction: 'BTTS',
            odds: bttsOdds,
            category: 'GG Tips',  // "Goal-Goal" / Both Teams To Score
            isPremium: random.nextBool(),
          ));
        }
      }

      return bttsTips;
    } catch (e) {
      print('Error getting BTTS tips: $e');
      throw Exception('Error getting BTTS tips: $e');
    }
  }

  // Get Premium Tips - collection of best tips marked as premium
  Future<List<Tip>> getPremiumTips() async {
    try {
      // Get tips from different categories
      final sureBets = await getSureBets();
      final overTips = await getOverTips();
      final underTips = await getUnderTips();
      final dailyHighOdds = await getDailyHighOdds();
      final superDraws = await getSuperDraws();
      final bttsTips = await getBTTS();

      // Combine all tips
      List<Tip> allTips = [
        ...sureBets,
        ...overTips,
        ...underTips,
        ...dailyHighOdds,
        ...superDraws,
        ...bttsTips
      ];

      // Filter only premium tips
      List<Tip> premiumTips = allTips.where((tip) => tip.isPremium).toList();

      // Sort by odds (lowest first, as they're most likely)
      premiumTips.sort((a, b) => a.odds.compareTo(b.odds));

      // Return top premium tips
      return premiumTips.take(10).toList();
    } catch (e) {
      print('Error getting premium tips: $e');
      throw Exception('Error getting premium tips: $e');
    }
  }

  // Get all free tips
  Future<List<Tip>> getFreeTips() async {
    try {
      // Get tips from different categories
      final sureBets = await getSureBets();
      final overTips = await getOverTips();
      final underTips = await getUnderTips();
      final dailyHighOdds = await getDailyHighOdds();
      final superDraws = await getSuperDraws();
      final bttsTips = await getBTTS();

      // Combine all tips
      List<Tip> allTips = [
        ...sureBets,
        ...overTips,
        ...underTips,
        ...dailyHighOdds,
        ...superDraws,
        ...bttsTips
      ];

      // Filter only free tips
      List<Tip> freeTips = allTips.where((tip) => !tip.isPremium).toList();

      // Limit results
      return freeTips.take(20).toList();
    } catch (e) {
      print('Error getting free tips: $e');
      throw Exception('Error getting free tips: $e');
    }
  }

  // Get tips by category
  Future<List<Tip>> getTipsByCategory(String category) async {
    try {
      switch (category.toLowerCase()) {
        case 'sure bets':
          return getSureBets();
        case 'over tips':
          return getOverTips();
        case 'under tips':
          return getUnderTips();
        case 'daily 2+ odds':
          return getDailyHighOdds();
        case 'super draws':
          return getSuperDraws();
        case 'gg tips':
          return getBTTS();
        case 'premium tips':
          return getPremiumTips();
        default:
          return getFreeTips();
      }
    } catch (e) {
      print('Error getting tips by category: $e');
      throw Exception('Error getting tips by category: $e');
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
          // Find the h2h market
          var h2hMarket = bookmaker['markets'].firstWhere(
                (market) => market['key'] == 'h2h',
            orElse: () => {'outcomes': []},
          );

          if (h2hMarket['outcomes'] != null) {
            for (var outcome in h2hMarket['outcomes']) {
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