///models/tip.dart
library;
import 'match.dart';

enum TipResult { win, loss, pending }

class Tip {
  final String id;
  final Match match;
  final String prediction;
  final double odds;
  final TipResult result;
  final String? score;
  final bool isPremium;
  final String? category; // e.g., "Sure Bets", "Daily 2+", etc.

  Tip({
    required this.id,
    required this.match,
    required this.prediction,
    required this.odds,
    this.result = TipResult.pending,
    this.score,
    this.isPremium = false,
    this.category,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'] ?? '',
      match: Match.fromJson(json['match']),
      prediction: json['prediction'] ?? '',
      odds: (json['odds'] is int)
          ? (json['odds'] as int).toDouble()
          : (json['odds'] ?? 0.0),
      result: _parseResult(json['result']),
      score: json['score'],
      isPremium: json['isPremium'] ?? false,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match': match.toJson(),
      'prediction': prediction,
      'odds': odds,
      'result': result.name,
      'score': score,
      'isPremium': isPremium,
      'category': category,
    };
  }

  static TipResult _parseResult(dynamic result) {
    if (result == null) return TipResult.pending;

    if (result is String) {
      try {
        return TipResult.values.byName(result.toLowerCase());
      } catch (_) {
        return TipResult.pending;
      }
    }

    return TipResult.pending;
  }
}
