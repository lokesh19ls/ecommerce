import '../entities/wishlist_item.dart';

abstract class WishlistRepository {
  Future<List<WishlistItem>> getWishlistItems();
  Future<void> addToWishlist(WishlistItem wishlistItem);
  Future<void> removeFromWishlist(String wishlistItemId);
  Future<void> clearWishlist();
  Future<bool> isProductInWishlist(int productId);
}
