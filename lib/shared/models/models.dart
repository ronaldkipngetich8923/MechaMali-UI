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
        id:            json['id'],
        homeTeam:      json['homeTeam'],
        homeTeamLogo:  json['homeTeamLogo'] ?? '',
        awayTeam:      json['awayTeam'],
        awayTeamLogo:  json['awayTeamLogo'] ?? '',
        league:        json['league'],
        leagueRegion:  json['leagueRegion'],
        kickOff:       DateTime.parse(json['kickOff']),
        status:        json['status'],
        homeScore:     json['homeScore'],
        awayScore:     json['awayScore'],
        minute:        json['minute'],
        venue:         json['venue'],
        isWatched:     json['isWatched'] ?? false,
      );

  MatchModel copyWith({bool? isWatched}) => MatchModel(
        id:            id,
        homeTeam:      homeTeam,
        homeTeamLogo:  homeTeamLogo,
        awayTeam:      awayTeam,
        awayTeamLogo:  awayTeamLogo,
        league:        league,
        leagueRegion:  leagueRegion,
        kickOff:       kickOff,
        status:        status,
        homeScore:     homeScore,
        awayScore:     awayScore,
        minute:        minute,
        venue:         venue,
        isWatched:     isWatched ?? this.isWatched,
      );
}

class InsightModel {
  final String matchId;
  final String insightText;
  final String? homeFormSummary;
  final String? awayFormSummary;
  final String? headToHeadSummary;
  final double? homeWinProbability;
  final double? drawProbability;
  final double? awayWinProbability;
  final bool isVipOnly;
  final DateTime generatedAt;

  const InsightModel({
    required this.matchId,
    required this.insightText,
    this.homeFormSummary,
    this.awayFormSummary,
    this.headToHeadSummary,
    this.homeWinProbability,
    this.drawProbability,
    this.awayWinProbability,
    required this.isVipOnly,
    required this.generatedAt,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) => InsightModel(
        matchId:             json['matchId'],
        insightText:         json['insightText'],
        homeFormSummary:     json['homeFormSummary'],
        awayFormSummary:     json['awayFormSummary'],
        headToHeadSummary:   json['headToHeadSummary'],
        homeWinProbability:  json['homeWinProbability']?.toDouble(),
        drawProbability:     json['drawProbability']?.toDouble(),
        awayWinProbability:  json['awayWinProbability']?.toDouble(),
        isVipOnly:           json['isVipOnly'] ?? true,
        generatedAt:         DateTime.parse(json['generatedAt']),
      );
}

class UserModel {
  final String id;
  final String name;
  final String phone;
  final bool isVip;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.isVip,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id:    json['id'],
        name:  json['name'],
        phone: json['phone'],
        isVip: json['isVip'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id':    id,
        'name':  name,
        'phone': phone,
        'isVip': isVip,
      };
}
