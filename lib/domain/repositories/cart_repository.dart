import '../entities/cart.dart';

abstract class CartRepository {
  // Get all carts
  Future<Map<String, dynamic>> getCarts({
    int? limit,
    int? skip,
  });

  // Get a single cart by ID
  Future<Cart> getCart(int cartId);

  // Get carts by user ID
  Future<Map<String, dynamic>> getCartsByUser(int userId);

  // Add a new cart
  Future<Cart> addCart({
    required int userId,
    required List<Map<String, dynamic>> products,
  });

  // Update a cart
  Future<Cart> updateCart({
    required int cartId,
    required int userId,
    required List<Map<String, dynamic>> products,
    bool merge = false,
  });

  // Delete a cart
  Future<Map<String, dynamic>> deleteCart(int cartId);
}