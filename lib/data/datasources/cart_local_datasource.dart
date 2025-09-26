import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCachedCartItems();
  Future<void> cacheCartItems(List<CartItemModel> cartItems);
  Future<void> addCartItem(CartItemModel cartItem);
  Future<void> removeCartItem(String cartItemId);
  Future<void> updateCartItemQuantity(String cartItemId, int quantity);
  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences _sharedPreferences;

  CartLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  @override
  Future<List<CartItemModel>> getCachedCartItems() async {
    try {
      final cartItemsJson = _sharedPreferences.getString(AppConstants.cartKey);
      if (cartItemsJson != null) {
        final List<dynamic> cartItemsList = json.decode(cartItemsJson);
        return cartItemsList
            .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw const CacheFailure(message: 'Failed to get cached cart items');
    }
  }

  @override
  Future<void> cacheCartItems(List<CartItemModel> cartItems) async {
    try {
      final cartItemsJson = json.encode(
        cartItems.map((item) => item.toJson()).toList(),
      );
      await _sharedPreferences.setString(AppConstants.cartKey, cartItemsJson);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to cache cart items');
    }
  }

  @override
  Future<void> addCartItem(CartItemModel cartItem) async {
    try {
      final cartItems = await getCachedCartItems();
      
      // Check if item already exists
      final existingIndex = cartItems.indexWhere((item) => item.product.id == cartItem.product.id);
      
      if (existingIndex != -1) {
        // Update quantity if item exists
        cartItems[existingIndex] = cartItems[existingIndex].copyWith(
          quantity: cartItems[existingIndex].quantity + cartItem.quantity,
        );
      } else {
        // Add new item
        cartItems.add(cartItem);
      }
      
      await cacheCartItems(cartItems);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to add cart item');
    }
  }

  @override
  Future<void> removeCartItem(String cartItemId) async {
    try {
      final cartItems = await getCachedCartItems();
      cartItems.removeWhere((item) => item.id == cartItemId);
      await cacheCartItems(cartItems);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to remove cart item');
    }
  }

  @override
  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    try {
      final cartItems = await getCachedCartItems();
      final itemIndex = cartItems.indexWhere((item) => item.id == cartItemId);
      
      if (itemIndex != -1) {
        if (quantity <= 0) {
          cartItems.removeAt(itemIndex);
        } else {
          cartItems[itemIndex] = cartItems[itemIndex].copyWith(quantity: quantity);
        }
        await cacheCartItems(cartItems);
      }
    } catch (e) {
      throw const CacheFailure(message: 'Failed to update cart item quantity');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _sharedPreferences.remove(AppConstants.cartKey);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to clear cart');
    }
  }
}
