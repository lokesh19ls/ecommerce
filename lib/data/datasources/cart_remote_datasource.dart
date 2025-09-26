import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../models/cart_api_model.dart';

abstract class CartRemoteDataSource {
  // Get all carts
  Future<Map<String, dynamic>> getCarts({
    int? limit,
    int? skip,
  });

  // Get a single cart by ID
  Future<CartApiModel> getCart(int cartId);

  // Get carts by user ID
  Future<Map<String, dynamic>> getCartsByUser(int userId);

  // Add a new cart
  Future<CartApiModel> addCart({
    required int userId,
    required List<Map<String, dynamic>> products,
  });

  // Update a cart
  Future<CartApiModel> updateCart({
    required int cartId,
    required int userId,
    required List<Map<String, dynamic>> products,
    bool merge = false,
  });

  // Delete a cart
  Future<Map<String, dynamic>> deleteCart(int cartId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient _apiClient;

  CartRemoteDataSourceImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> getCarts({
    int? limit,
    int? skip,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      
      if (limit != null) queryParameters['limit'] = limit;
      if (skip != null) queryParameters['skip'] = skip;

      final response = await _apiClient.get(
        ApiConstants.cartsEndpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        print('DEBUG: CartRemoteDataSource - Fetched ${data['carts']?.length ?? 0} carts');
        return data;
      }

      throw const ServerFailure(message: 'Failed to fetch carts');
    } on DioException catch (e) {
      print('DEBUG: CartRemoteDataSource - DioException: ${e.message}');
      throw const ServerFailure(message: 'Failed to fetch carts');
    } catch (e) {
      print('DEBUG: CartRemoteDataSource - Error: $e');
      throw const ServerFailure(message: 'Failed to fetch carts');
    }
  }

  @override
  Future<CartApiModel> getCart(int cartId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.cartByIdEndpoint}/$cartId',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        print('DEBUG: CartRemoteDataSource - Fetched cart $cartId');
        return CartApiModel.fromJson(data);
      }

      throw const ServerFailure(message: 'Failed to fetch cart');
    } on DioException catch (e) {
      print('DEBUG: CartRemoteDataSource - DioException: ${e.message}');
      throw const ServerFailure(message: 'Failed to fetch cart');
    } catch (e) {
      print('DEBUG: CartRemoteDataSource - Error: $e');
      throw const ServerFailure(message: 'Failed to fetch cart');
    }
  }

  @override
  Future<Map<String, dynamic>> getCartsByUser(int userId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.cartByUserEndpoint}/$userId',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        print('DEBUG: CartRemoteDataSource - Fetched carts for user $userId');
        return data;
      }

      throw const ServerFailure(message: 'Failed to fetch user carts');
    } on DioException catch (e) {
      print('DEBUG: CartRemoteDataSource - DioException: ${e.message}');
      throw const ServerFailure(message: 'Failed to fetch user carts');
    } catch (e) {
      print('DEBUG: CartRemoteDataSource - Error: $e');
      throw const ServerFailure(message: 'Failed to fetch user carts');
    }
  }

  @override
  Future<CartApiModel> addCart({
    required int userId,
    required List<Map<String, dynamic>> products,
  }) async {
    try {
      final requestData = {
        'userId': userId,
        'products': products,
      };

      final response = await _apiClient.post(
        ApiConstants.addCartEndpoint,
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        print('DEBUG: CartRemoteDataSource - Added cart for user $userId');
        return CartApiModel.fromJson(data);
      }

      throw const ServerFailure(message: 'Failed to add cart');
    } on DioException catch (e) {
      print('DEBUG: CartRemoteDataSource - DioException: ${e.message}');
      throw const ServerFailure(message: 'Failed to add cart');
    } catch (e) {
      print('DEBUG: CartRemoteDataSource - Error: $e');
      throw const ServerFailure(message: 'Failed to add cart');
    }
  }

  @override
  Future<CartApiModel> updateCart({
    required int cartId,
    required int userId,
    required List<Map<String, dynamic>> products,
    bool merge = false,
  }) async {
    try {
      final requestData = {
        'userId': userId,
        'products': products,
        if (merge) 'merge': true,
      };

      final response = await _apiClient.put(
        '${ApiConstants.updateCartEndpoint}/$cartId',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        print('DEBUG: CartRemoteDataSource - Updated cart $cartId');
        return CartApiModel.fromJson(data);
      }

      throw const ServerFailure(message: 'Failed to update cart');
    } on DioException catch (e) {
      print('DEBUG: CartRemoteDataSource - DioException: ${e.message}');
      throw const ServerFailure(message: 'Failed to update cart');
    } catch (e) {
      print('DEBUG: CartRemoteDataSource - Error: $e');
      throw const ServerFailure(message: 'Failed to update cart');
    }
  }

  @override
  Future<Map<String, dynamic>> deleteCart(int cartId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.deleteCartEndpoint}/$cartId',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        print('DEBUG: CartRemoteDataSource - Deleted cart $cartId');
        return data;
      }

      throw const ServerFailure(message: 'Failed to delete cart');
    } on DioException catch (e) {
      print('DEBUG: CartRemoteDataSource - DioException: ${e.message}');
      throw const ServerFailure(message: 'Failed to delete cart');
    } catch (e) {
      print('DEBUG: CartRemoteDataSource - Error: $e');
      throw const ServerFailure(message: 'Failed to delete cart');
    }
  }
}
