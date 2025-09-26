import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  // Get all products with pagination and filtering
  Future<Map<String, dynamic>> getProducts({
    int? limit,
    int? skip,
    String? select,
    String? sortBy,
    String? order,
  });
  
  // Get a single product by ID
  Future<ProductModel> getProduct(int id);
  
  // Search products
  Future<Map<String, dynamic>> searchProducts(String query);
  
  // Get all product categories
  Future<List<String>> getCategories();
  
  // Get products by category
  Future<Map<String, dynamic>> getProductsByCategory(String category);
  
  // Add a new product (simulated)
  Future<ProductModel> addProduct(Map<String, dynamic> productData);
  
  // Update a product (simulated)
  Future<ProductModel> updateProduct(int id, Map<String, dynamic> productData);
  
  // Delete a product (simulated)
  Future<ProductModel> deleteProduct(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> getProducts({
    int? limit,
    int? skip,
    String? select,
    String? sortBy,
    String? order,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      
      if (limit != null) queryParameters['limit'] = limit;
      if (skip != null) queryParameters['skip'] = skip;
      if (select != null) queryParameters['select'] = select;
      if (sortBy != null) queryParameters['sortBy'] = sortBy;
      if (order != null) queryParameters['order'] = order;

      final response = await _apiClient.get(
        ApiConstants.productsEndpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        print('DEBUG: RemoteDataSource - Response data keys: ${data.keys.toList()}');
        print('DEBUG: RemoteDataSource - Products count: ${(data['products'] as List<dynamic>).length}');
        
        final products = (data['products'] as List<dynamic>)
            .map((json) {
              print('DEBUG: RemoteDataSource - Parsing product: ${json['id']}');
              return ProductModel.fromJson(json as Map<String, dynamic>);
            })
            .toList();
        
        print('DEBUG: RemoteDataSource - Successfully parsed ${products.length} products');
        return {
          'products': products,
          'total': data['total'] as int,
          'skip': data['skip'] as int,
          'limit': data['limit'] as int,
        };
      }

      throw const ServerFailure(message: 'Failed to fetch products');
    } on DioException catch (e) {
      throw const ServerFailure(message: 'Failed to fetch products');
    } catch (e) {
      throw const ServerFailure(message: 'Failed to fetch products');
    }
  }

  @override
  Future<ProductModel> getProduct(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.productsEndpoint}/$id');

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw const ServerFailure(message: 'Failed to fetch product');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const ServerFailure(message: 'Product not found');
      }
      throw const ServerFailure(message: 'Failed to fetch product');
    } catch (e) {
      throw const ServerFailure(message: 'Failed to fetch product');
    }
  }

  @override
  Future<Map<String, dynamic>> searchProducts(String query) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.productSearchEndpoint,
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final products = (data['products'] as List<dynamic>)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return {
          'products': products,
          'total': data['total'] as int,
          'skip': data['skip'] as int,
          'limit': data['limit'] as int,
        };
      }

      throw const ServerFailure(message: 'Failed to search products');
    } on DioException catch (e) {
      throw const ServerFailure(message: 'Failed to search products');
    } catch (e) {
      throw const ServerFailure(message: 'Failed to search products');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.productCategoriesEndpoint);

      if (response.statusCode == 200) {
        final List<dynamic> categories = response.data;
        print('DEBUG: Raw categories response: $categories');
        // The dummyjson.com categories endpoint returns objects with name field
        final categoryNames = categories.map((category) => category['name'] as String).toList();
        print('DEBUG: Parsed category names: $categoryNames');
        return categoryNames;
      }

      throw const ServerFailure(message: 'Failed to fetch categories');
    } on DioException catch (e) {
      throw const ServerFailure(message: 'Failed to fetch categories');
    } catch (e) {
      throw const ServerFailure(message: 'Failed to fetch categories');
    }
  }

  @override
  Future<Map<String, dynamic>> getProductsByCategory(String category) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.productByCategoryEndpoint}/$category',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final products = (data['products'] as List<dynamic>)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return {
          'products': products,
          'total': data['total'] as int,
          'skip': data['skip'] as int,
          'limit': data['limit'] as int,
        };
      }

      throw const ServerFailure(message: 'Failed to fetch products by category');
    } on DioException catch (e) {
      throw const ServerFailure(message: 'Failed to fetch products by category');
    } catch (e) {
      throw const ServerFailure(message: 'Failed to fetch products by category');
    }
  }

  @override
  Future<ProductModel> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.addProductEndpoint,
        data: productData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw const ServerFailure(message: 'Failed to add product');
    } on DioException catch (e) {
      throw const ServerFailure(message: 'Failed to add product');
    } catch (e) {
      throw const ServerFailure(message: 'Failed to add product');
    }
  }

  @override
  Future<ProductModel> updateProduct(int id, Map<String, dynamic> productData) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.updateProductEndpoint}/$id',
        data: productData,
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw const ServerFailure(message: 'Failed to update product');
    } on DioException catch (e) {
      throw const ServerFailure(message: 'Failed to update product');
    } catch (e) {
      throw const ServerFailure(message: 'Failed to update product');
    }
  }

  @override
  Future<ProductModel> deleteProduct(int id) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.deleteProductEndpoint}/$id',
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw const ServerFailure(message: 'Failed to delete product');
    } on DioException catch (e) {
      throw const ServerFailure(message: 'Failed to delete product');
    } catch (e) {
      throw const ServerFailure(message: 'Failed to delete product');
    }
  }
}
