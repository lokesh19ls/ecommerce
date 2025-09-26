import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../models/wishlist_item_model.dart';

abstract class WishlistLocalDataSource {
  Future<List<WishlistItemModel>> getCachedWishlistItems();
  Future<void> cacheWishlistItems(List<WishlistItemModel> wishlistItems);
  Future<void> addWishlistItem(WishlistItemModel wishlistItem);
  Future<void> removeWishlistItem(String wishlistItemId);
  Future<void> clearWishlist();
  Future<bool> isProductInWishlist(int productId);
}

class WishlistLocalDataSourceImpl implements WishlistLocalDataSource {
  final SharedPreferences _sharedPreferences;

  WishlistLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  @override
  Future<List<WishlistItemModel>> getCachedWishlistItems() async {
    try {
      final wishlistItemsJson = _sharedPreferences.getString(AppConstants.wishlistKey);
      if (wishlistItemsJson != null) {
        final List<dynamic> wishlistItemsList = json.decode(wishlistItemsJson);
        return wishlistItemsList
            .map((json) => WishlistItemModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw const CacheFailure(message: 'Failed to get cached wishlist items');
    }
  }

  @override
  Future<void> cacheWishlistItems(List<WishlistItemModel> wishlistItems) async {
    try {
      final wishlistItemsJson = json.encode(
        wishlistItems.map((item) => item.toJson()).toList(),
      );
      await _sharedPreferences.setString(AppConstants.wishlistKey, wishlistItemsJson);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to cache wishlist items');
    }
  }

  @override
  Future<void> addWishlistItem(WishlistItemModel wishlistItem) async {
    try {
      final wishlistItems = await getCachedWishlistItems();
      
      // Check if item already exists
      final existingIndex = wishlistItems.indexWhere(
        (item) => item.product.id == wishlistItem.product.id,
      );
      
      if (existingIndex == -1) {
        // Add new item only if it doesn't exist
        wishlistItems.add(wishlistItem);
        await cacheWishlistItems(wishlistItems);
      }
    } catch (e) {
      throw const CacheFailure(message: 'Failed to add wishlist item');
    }
  }

  @override
  Future<void> removeWishlistItem(String wishlistItemId) async {
    try {
      final wishlistItems = await getCachedWishlistItems();
      wishlistItems.removeWhere((item) => item.id == wishlistItemId);
      await cacheWishlistItems(wishlistItems);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to remove wishlist item');
    }
  }

  @override
  Future<void> clearWishlist() async {
    try {
      await _sharedPreferences.remove(AppConstants.wishlistKey);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to clear wishlist');
    }
  }

  @override
  Future<bool> isProductInWishlist(int productId) async {
    try {
      final wishlistItems = await getCachedWishlistItems();
      return wishlistItems.any((item) => item.product.id == productId);
    } catch (e) {
      return false;
    }
  }
}
