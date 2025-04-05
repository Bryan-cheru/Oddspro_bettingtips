
// models/match.dart
class Match {
  final String id;
  final String country;
  final String homeTeam;
  final String awayTeam;
  final DateTime matchDate;
  final String timeEAT;
  final String? league;
  final String? logoUrl;
  final double homeOdds;
  final double awayOdds;
  final double drawOdds;
  final int? homeScore;
  final int? awayScore;
  final String status; // 'scheduled', 'in_progress', 'completed'

  Match({
    required this.id,
    required this.country,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchDate,
    required this.timeEAT,
    this.league,
    this.logoUrl,
    this.homeOdds = 0,
    this.awayOdds = 0,
    this.drawOdds = 0,
    this.homeScore,
    this.awayScore,
    this.status = 'scheduled',
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] ?? '',
      country: json['country'] ?? '',
      homeTeam: json['homeTeam'] ?? '',
      awayTeam: json['awayTeam'] ?? '',
      matchDate: json['matchDate'] != null
          ? (json['matchDate'] is String
              ? DateTime.parse(json['matchDate'])
              : (json['matchDate'])) // Handling Firestore Timestamp
          : DateTime.now(),
      timeEAT: json['timeEAT'] ?? '',
      league: json['league'],
      logoUrl: json['logoUrl'],
      homeOdds: (json['homeOdds'] ?? 0).toDouble(),
      awayOdds: (json['awayOdds'] ?? 0).toDouble(),
      drawOdds: (json['drawOdds'] ?? 0).toDouble(),
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      status: json['status'] ?? 'scheduled',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'matchDate': matchDate.toIso8601String(),
      'timeEAT': timeEAT,
      'league': league,
      'logoUrl': logoUrl,
      'homeOdds': homeOdds,
      'awayOdds': awayOdds,
      'drawOdds': drawOdds,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'status': status,
    };
  }
}
