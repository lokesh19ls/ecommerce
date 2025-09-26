import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/local_cart_repository.dart';
import '../models/cart_item_model.dart';

class LocalCartRepositoryImpl implements LocalCartRepository {
  static const String _cartItemsKey = 'cart_items';
  
  @override
  Future<List<CartItemEntity>> getCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartItemsJson = prefs.getStringList(_cartItemsKey) ?? [];
      
      return cartItemsJson
          .map((json) => CartItemModel.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<double> getCartTotal() async {
    final cartItems = await getCartItems();
    double total = 0.0;
    for (final item in cartItems) {
      total += item.product.price * item.quantity;
    }
    return total;
  }
  
  @override
  Future<int> getCartItemCount() async {
    final cartItems = await getCartItems();
    int count = 0;
    for (final item in cartItems) {
      count += item.quantity;
    }
    return count;
  }
  
  @override
  Future<void> addCartItem(Product product, int quantity) async {
    final cartItems = await getCartItems();
    
    // Check if item already exists
    final existingIndex = cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );
    
    if (existingIndex != -1) {
      // Update existing item quantity
      final existingItem = cartItems[existingIndex];
      final updatedItem = CartItemModel(
        id: existingItem.id,
        product: existingItem.product,
        quantity: existingItem.quantity + quantity,
        addedAt: existingItem.addedAt,
      );
      cartItems[existingIndex] = updatedItem;
    } else {
      // Add new item
      final newItem = CartItemModel(
        id: product.id.toString(),
        product: product,
        quantity: quantity,
        addedAt: DateTime.now(),
      );
      cartItems.add(newItem);
    }
    
    await _saveCartItems(cartItems);
  }
  
  @override
  Future<void> removeCartItem(String cartItemId) async {
    final cartItems = await getCartItems();
    cartItems.removeWhere((item) => item.id.toString() == cartItemId);
    await _saveCartItems(cartItems);
  }
  
  @override
  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    final cartItems = await getCartItems();
    final index = cartItems.indexWhere((item) => item.id.toString() == cartItemId);
    
    if (index != -1) {
      final item = cartItems[index];
      final updatedItem = CartItemModel(
        id: item.id,
        product: item.product,
        quantity: quantity,
        addedAt: item.addedAt,
      );
      cartItems[index] = updatedItem;
      await _saveCartItems(cartItems);
    }
  }
  
  @override
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartItemsKey);
  }
  
  Future<void> _saveCartItems(List<CartItemEntity> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    final cartItemsJson = cartItems
        .map((item) => jsonEncode((item as CartItemModel).toJson()))
        .toList();
    await prefs.setStringList(_cartItemsKey, cartItemsJson);
  }
}
