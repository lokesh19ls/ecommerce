import '../entities/cart_item_entity.dart';
import '../entities/product.dart';

abstract class LocalCartRepository {
  // Get all cart items
  Future<List<CartItemEntity>> getCartItems();
  
  // Get cart total
  Future<double> getCartTotal();
  
  // Get cart item count
  Future<int> getCartItemCount();
  
  // Add item to cart
  Future<void> addCartItem(Product product, int quantity);
  
  // Remove item from cart
  Future<void> removeCartItem(String cartItemId);
  
  // Update item quantity
  Future<void> updateCartItemQuantity(String cartItemId, int quantity);
  
  // Clear cart
  Future<void> clearCart();
}
