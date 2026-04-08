// lib/core/constants/kenyan_football.dart
class KenyanFootballConstants {
  // Kenyan Premier League Teams
  static const List<String> kplTeams = [
    'Gor Mahia', 'AFC Leopards', 'KCB', 'Tusker', 'Bandari',
    'Kariobangi Sharks', 'Wazito', 'Kakamega Homeboyz',
    'Ulinzi Stars', 'Sofapaka', 'Mathare United', 'Wazito'
  ];

  // Derby matches (high engagement)
  static const Map<String, List<String>> derbies = {
    'Mashemeji Derby': ['Gor Mahia', 'AFC Leopards'],
    'Nakuru Derby': ['Ulinzi Stars', 'Wazito'],
    'Mombasa Derby': ['Bandari', 'Coast Stalions'],
  };

  // Betting regions
  static const List<String> bettingRegions = [
    'Nairobi', 'Mombasa', 'Kisumu', 'Nakuru', 'Eldoret', 'Thika'
  ];
}