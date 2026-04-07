class MatchModel {
  final String id;
  final String homeTeam;
  final String homeTeamLogo;
  final String awayTeam;
  final String awayTeamLogo;
  final String league;
  final String leagueRegion;
  final DateTime kickOff;
  final String status;
  final int? homeScore;
  final int? awayScore;
  final int? minute;
  final String? venue;
  final bool isWatched;

  const MatchModel({
    required this.id,
    required this.homeTeam,
    required this.homeTeamLogo,
    required this.awayTeam,
    required this.awayTeamLogo,
    required this.league,
    required this.leagueRegion,
    required this.kickOff,
    required this.status,
    this.homeScore,
    this.awayScore,
    this.minute,
    this.venue,
    this.isWatched = false,
  });

  bool get isLive => status == 'Live' || status == 'HalfTime';
  bool get isFinished => status == 'Finished';

  factory MatchModel.fromJson(Map<String, dynamic> json) => MatchModel(
        id: json['id'] as String,
        homeTeam: json['homeTeam'] as String,
        homeTeamLogo: json['homeTeamLogo'] as String? ?? '',
        awayTeam: json['awayTeam'] as String,
        awayTeamLogo: json['awayTeamLogo'] as String? ?? '',
        league: json['league'] as String,
        leagueRegion: json['leagueRegion'] as String? ?? '',
        kickOff: DateTime.parse(json['kickOff'] as String),
        status: json['status'] as String,
        homeScore: json['homeScore'] as int?,
        awayScore: json['awayScore'] as int?,
        minute: json['minute'] as int?,
        venue: json['venue'] as String?,
        isWatched: json['isWatched'] as bool? ?? false,
      );
}
