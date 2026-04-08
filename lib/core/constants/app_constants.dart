class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'http://192.168.100.24:51463/api';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Storage keys
  static const String accessTokenKey  = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey         = 'user_data';

  // Subscription plans
  static const String planMonthly   = 'VipMonthly';
  static const String planQuarterly = 'VipQuarterly';

  // M-Pesa pricing (KES)
  static const int priceMonthly   = 150;
  static const int priceQuarterly = 350;

  // League regions
  static const String regionKenya         = 'Kenya';
  static const String regionAfrica        = 'Africa';
  static const String regionInternational = 'International';
}
