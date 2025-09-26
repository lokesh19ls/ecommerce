import '../../core/errors/failures.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;

  CartRepositoryImpl({
    required CartRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Map<String, dynamic>> getCarts({
    int? limit,
    int? skip,
  }) async {
    try {
      print('DEBUG: CartRepository - Starting to fetch carts...');
      final result = await _remoteDataSource.getCarts(
        limit: limit,
        skip: skip,
      );
      
      print('DEBUG: CartRepository - Carts fetched successfully');
      return result;
    } on ServerFailure catch (failure) {
      print('DEBUG: CartRepository - ServerFailure: ${failure.message}');
      throw failure;
    } catch (e) {
      print('DEBUG: CartRepository - Unexpected error: $e');
      throw const ServerFailure(message: 'An unexpected error occurred');
    }
  }

  @override
  Future<Cart> getCart(int cartId) async {
    try {
      print('DEBUG: CartRepository - Starting to fetch cart $cartId...');
      final cartModel = await _remoteDataSource.getCart(cartId);
      final cart = cartModel.toEntity();
      
      print('DEBUG: CartRepository - Cart $cartId fetched successfully');
      return cart;
    } on ServerFailure catch (failure) {
      print('DEBUG: CartRepository - ServerFailure: ${failure.message}');
      throw failure;
    } catch (e) {
      print('DEBUG: CartRepository - Unexpected error: $e');
      throw const ServerFailure(message: 'An unexpected error occurred');
    }
  }

  @override
  Future<Map<String, dynamic>> getCartsByUser(int userId) async {
    try {
      print('DEBUG: CartRepository - Starting to fetch carts for user $userId...');
      final result = await _remoteDataSource.getCartsByUser(userId);
      
      print('DEBUG: CartRepository - User carts fetched successfully');
      return result;
    } on ServerFailure catch (failure) {
      print('DEBUG: CartRepository - ServerFailure: ${failure.message}');
      throw failure;
    } catch (e) {
      print('DEBUG: CartRepository - Unexpected error: $e');
      throw const ServerFailure(message: 'An unexpected error occurred');
    }
  }

  @override
  Future<Cart> addCart({
    required int userId,
    required List<Map<String, dynamic>> products,
  }) async {
    try {
      print('DEBUG: CartRepository - Starting to add cart for user $userId...');
      final cartModel = await _remoteDataSource.addCart(
        userId: userId,
        products: products,
      );
      final cart = cartModel.toEntity();
      
      print('DEBUG: CartRepository - Cart added successfully');
      return cart;
    } on ServerFailure catch (failure) {
      print('DEBUG: CartRepository - ServerFailure: ${failure.message}');
      throw failure;
    } catch (e) {
      print('DEBUG: CartRepository - Unexpected error: $e');
      throw const ServerFailure(message: 'An unexpected error occurred');
    }
  }

  @override
  Future<Cart> updateCart({
    required int cartId,
    required int userId,
    required List<Map<String, dynamic>> products,
    bool merge = false,
  }) async {
    try {
      print('DEBUG: CartRepository - Starting to update cart $cartId...');
      final cartModel = await _remoteDataSource.updateCart(
        cartId: cartId,
        userId: userId,
        products: products,
        merge: merge,
      );
      final cart = cartModel.toEntity();
      
      print('DEBUG: CartRepository - Cart $cartId updated successfully');
      return cart;
    } on ServerFailure catch (failure) {
      print('DEBUG: CartRepository - ServerFailure: ${failure.message}');
      throw failure;
    } catch (e) {
      print('DEBUG: CartRepository - Unexpected error: $e');
      throw const ServerFailure(message: 'An unexpected error occurred');
    }
  }

  @override
  Future<Map<String, dynamic>> deleteCart(int cartId) async {
    try {
      print('DEBUG: CartRepository - Starting to delete cart $cartId...');
      final result = await _remoteDataSource.deleteCart(cartId);
      
      print('DEBUG: CartRepository - Cart $cartId deleted successfully');
      return result;
    } on ServerFailure catch (failure) {
      print('DEBUG: CartRepository - ServerFailure: ${failure.message}');
      throw failure;
    } catch (e) {
      print('DEBUG: CartRepository - Unexpected error: $e');
      throw const ServerFailure(message: 'An unexpected error occurred');
    }
  }
}