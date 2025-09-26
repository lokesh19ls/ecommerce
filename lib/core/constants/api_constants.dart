class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://dummyjson.com';
  static const String authBaseUrl = 'https://dummyjson.com';
  
  // Auth Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String meEndpoint = '/auth/me';
  static const String refreshEndpoint = '/auth/refresh';
  
  // Product Endpoints
  static const String productsEndpoint = '/products';
  static const String productByIdEndpoint = '/products'; // /products/{id}
  static const String productSearchEndpoint = '/products/search';
  static const String productCategoriesEndpoint = '/products/categories';
  static const String productCategoryListEndpoint = '/products/category-list';
  static const String productByCategoryEndpoint = '/products/category'; // /products/category/{category}
  static const String addProductEndpoint = '/products/add';
  static const String updateProductEndpoint = '/products'; // /products/{id}
  static const String deleteProductEndpoint = '/products'; // /products/{id}
  
  // Sorting Parameters
  static const String sortByTitle = 'title';
  static const String sortByPrice = 'price';
  static const String sortByRating = 'rating';
  static const String sortByStock = 'stock';
  static const String sortByDiscount = 'discountPercentage';
  
  static const String orderAsc = 'asc';
  static const String orderDesc = 'desc';
  
  // Cart Endpoints
  static const String cartsEndpoint = '/carts';
  static const String cartByIdEndpoint = '/carts'; // /carts/{id}
  static const String cartByUserEndpoint = '/carts/user'; // /carts/user/{userId}
  static const String addCartEndpoint = '/carts/add';
  static const String updateCartEndpoint = '/carts'; // /carts/{id}
  static const String deleteCartEndpoint = '/carts'; // /carts/{id}
  
  // Other Endpoints
  static const String usersEndpoint = '/users';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
}
