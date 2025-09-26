import '../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  final ProductLocalDataSource _localDataSource;

  ProductRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
    required ProductLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Map<String, dynamic>> getProducts({
    int? limit,
    int? skip,
    String? select,
    String? sortBy,
    String? order,
  }) async {
    try {
      print('DEBUG: Repository - Starting to fetch products from remote...');
      // Try to get from remote first
      final result = await _remoteDataSource.getProducts(
        limit: limit,
        skip: skip,
        select: select,
        sortBy: sortBy,
        order: order,
      );
      
      print('DEBUG: Repository - Remote data source returned result');
      // Cache the products
      final productModels = result['products'] as List<ProductModel>;
      print('DEBUG: Repository - Products cast to ProductModel list, count: ${productModels.length}');
      await _localDataSource.cacheProducts(productModels);
      print('DEBUG: Repository - Products cached successfully');
      
      return result;
    } on NetworkFailure {
      // If network fails, try to get from cache
      try {
        final cachedProducts = await _localDataSource.getCachedProducts();
        if (cachedProducts.isNotEmpty) {
          // Apply filters to cached products
          var filteredProducts = cachedProducts;
          
          if (limit != null && limit > 0) {
            filteredProducts = filteredProducts.take(limit).toList();
          }
          
          return {
            'products': filteredProducts,
            'total': cachedProducts.length,
            'skip': skip ?? 0,
            'limit': limit ?? 30,
          };
        }
        rethrow;
      } catch (e) {
        throw const NetworkFailure(message: 'No internet connection and no cached data available');
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(message: 'Failed to fetch products');
    }
  }

  @override
  Future<Product> getProduct(int id) async {
    try {
      // Try to get from remote first
      final product = await _remoteDataSource.getProduct(id);
      
      // Cache the product
      await _localDataSource.cacheProduct(product);
      
      return product;
    } on NetworkFailure {
      // If network fails, try to get from cache
      try {
        final cachedProduct = await _localDataSource.getCachedProduct(id);
        if (cachedProduct != null) {
          return cachedProduct;
        }
        rethrow;
      } catch (e) {
        throw const NetworkFailure(message: 'No internet connection and product not cached');
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(message: 'Failed to fetch product');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      print('DEBUG: Repository - Starting to fetch categories from remote...');
      // Try to get from remote first
      final categories = await _remoteDataSource.getCategories();
      print('DEBUG: Repository - Categories fetched from remote, count: ${categories.length}');
      
      // Cache the categories
      await _localDataSource.cacheCategories(categories);
      print('DEBUG: Repository - Categories cached successfully');
      
      return categories;
    } on NetworkFailure {
      // If network fails, try to get from cache
      try {
        final cachedCategories = await _localDataSource.getCachedCategories();
        if (cachedCategories.isNotEmpty) {
          return cachedCategories;
        }
        rethrow;
      } catch (e) {
        throw const NetworkFailure(message: 'No internet connection and no cached categories');
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(message: 'Failed to fetch categories');
    }
  }

  @override
  Future<Map<String, dynamic>> searchProducts(String query) async {
    try {
      // Try to get from remote first
      final result = await _remoteDataSource.searchProducts(query);
      
      // Cache the products
      final productModels = result['products'] as List<ProductModel>;
      await _localDataSource.cacheProducts(productModels);
      
      return result;
    } on NetworkFailure {
      // If network fails, try to search in cache
      try {
        final cachedProducts = await _localDataSource.getCachedProducts();
        if (cachedProducts.isNotEmpty) {
          final filteredProducts = cachedProducts.where((product) {
            return product.title.toLowerCase().contains(query.toLowerCase()) ||
                   product.description.toLowerCase().contains(query.toLowerCase()) ||
                   product.category.toLowerCase().contains(query.toLowerCase());
          }).toList();
          
          return {
            'products': filteredProducts,
            'total': filteredProducts.length,
            'skip': 0,
            'limit': 30,
          };
        }
        rethrow;
      } catch (e) {
        throw const NetworkFailure(message: 'No internet connection and no cached data available');
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(message: 'Failed to search products');
    }
  }

  @override
  Future<Map<String, dynamic>> getProductsByCategory(String category) async {
    try {
      // Try to get from remote first
      final result = await _remoteDataSource.getProductsByCategory(category);
      
      // Cache the products
      final productModels = result['products'] as List<ProductModel>;
      await _localDataSource.cacheProducts(productModels);
      
      return result;
    } on NetworkFailure {
      // If network fails, try to get from cache
      try {
        final cachedProducts = await _localDataSource.getCachedProducts();
        if (cachedProducts.isNotEmpty) {
          final filteredProducts = cachedProducts
              .where((product) => product.category.toLowerCase() == category.toLowerCase())
              .toList();
          
          return {
            'products': filteredProducts,
            'total': filteredProducts.length,
            'skip': 0,
            'limit': 30,
          };
        }
        rethrow;
      } catch (e) {
        throw const NetworkFailure(message: 'No internet connection and no cached data available');
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(message: 'Failed to fetch products by category');
    }
  }

  @override
  Future<Product> addProduct(Map<String, dynamic> productData) async {
    try {
      final product = await _remoteDataSource.addProduct(productData);
      
      // Cache the new product
      await _localDataSource.cacheProduct(ProductModel.fromEntity(product));
      
      return product;
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(message: 'Failed to add product');
    }
  }

  @override
  Future<Product> updateProduct(int id, Map<String, dynamic> productData) async {
    try {
      final product = await _remoteDataSource.updateProduct(id, productData);
      
      // Update the cached product
      await _localDataSource.cacheProduct(ProductModel.fromEntity(product));
      
      return product;
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(message: 'Failed to update product');
    }
  }

  @override
  Future<Product> deleteProduct(int id) async {
    try {
      final product = await _remoteDataSource.deleteProduct(id);
      
      // Remove from cache
      await _localDataSource.removeCachedProduct(id);
      
      return product;
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(message: 'Failed to delete product');
    }
  }
}
