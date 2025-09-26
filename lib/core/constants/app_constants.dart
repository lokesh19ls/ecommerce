class AppConstants {
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String cartKey = 'cart_items';
  static const String wishlistKey = 'wishlist_items';
  static const String cachedProductsKey = 'cached_products';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Duration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const Duration shortCacheExpiration = Duration(minutes: 30);
  
  // App Info
  static const String appName = 'E-Commerce App';
  static const String appVersion = '1.0.0';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
}
