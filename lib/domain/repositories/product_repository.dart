import '../entities/product.dart';

abstract class ProductRepository {
  // Get all products with pagination and filtering
  Future<Map<String, dynamic>> getProducts({
    int? limit,
    int? skip,
    String? select,
    String? sortBy,
    String? order,
  });
  
  // Get a single product by ID
  Future<Product> getProduct(int id);
  
  // Search products
  Future<Map<String, dynamic>> searchProducts(String query);
  
  // Get all product categories
  Future<List<String>> getCategories();
  
  // Get products by category
  Future<Map<String, dynamic>> getProductsByCategory(String category);
  
  // Add a new product (simulated)
  Future<Product> addProduct(Map<String, dynamic> productData);
  
  // Update a product (simulated)
  Future<Product> updateProduct(int id, Map<String, dynamic> productData);
  
  // Delete a product (simulated)
  Future<Product> deleteProduct(int id);
}
