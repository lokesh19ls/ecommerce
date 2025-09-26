import '../../core/errors/failures.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_local_datasource.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistLocalDataSource _localDataSource;

  WishlistRepositoryImpl({
    required WishlistLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<List<WishlistItem>> getWishlistItems() async {
    try {
      return await _localDataSource.getCachedWishlistItems();
    } on Failure {
      rethrow;
    } catch (e) {
      throw const CacheFailure(message: 'Failed to get wishlist items');
    }
  }

  @override
  Future<void> addToWishlist(WishlistItem wishlistItem) async {
    try {
      await _localDataSource.addWishlistItem(wishlistItem as dynamic);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const CacheFailure(message: 'Failed to add item to wishlist');
    }
  }

  @override
  Future<void> removeFromWishlist(String wishlistItemId) async {
    try {
      await _localDataSource.removeWishlistItem(wishlistItemId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const CacheFailure(message: 'Failed to remove item from wishlist');
    }
  }

  @override
  Future<void> clearWishlist() async {
    try {
      await _localDataSource.clearWishlist();
    } on Failure {
      rethrow;
    } catch (e) {
      throw const CacheFailure(message: 'Failed to clear wishlist');
    }
  }

  @override
  Future<bool> isProductInWishlist(int productId) async {
    try {
      return await _localDataSource.isProductInWishlist(productId);
    } on Failure {
      rethrow;
    } catch (e) {
      return false;
    }
  }
}
