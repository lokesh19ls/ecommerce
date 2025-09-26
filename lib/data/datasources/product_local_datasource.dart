import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getCachedProducts();
  Future<void> cacheProducts(List<ProductModel> products);
  Future<ProductModel?> getCachedProduct(int id);
  Future<void> cacheProduct(ProductModel product);
  Future<void> removeCachedProduct(int id);
  Future<List<String>> getCachedCategories();
  Future<void> cacheCategories(List<String> categories);
  Future<void> clearProductCache();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final SharedPreferences _sharedPreferences;

  ProductLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    try {
      final productsJson = _sharedPreferences.getString(AppConstants.cachedProductsKey);
      if (productsJson != null) {
        final List<dynamic> productsList = json.decode(productsJson);
        return productsList
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw const CacheFailure(message: 'Failed to get cached products');
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final productsJson = json.encode(
        products.map((product) => product.toJson()).toList(),
      );
      await _sharedPreferences.setString(AppConstants.cachedProductsKey, productsJson);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to cache products');
    }
  }

  @override
  Future<ProductModel?> getCachedProduct(int id) async {
    try {
      final products = await getCachedProducts();
      try {
        return products.firstWhere((product) => product.id == id);
      } catch (e) {
        return null;
      }
    } catch (e) {
      throw const CacheFailure(message: 'Failed to get cached product');
    }
  }

  @override
  Future<void> cacheProduct(ProductModel product) async {
    try {
      final products = await getCachedProducts();
      final existingIndex = products.indexWhere((p) => p.id == product.id);
      
      if (existingIndex != -1) {
        products[existingIndex] = product;
      } else {
        products.add(product);
      }
      
      await cacheProducts(products);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to cache product');
    }
  }

  @override
  Future<List<String>> getCachedCategories() async {
    try {
      final categoriesJson = _sharedPreferences.getString('cached_categories');
      if (categoriesJson != null) {
        final List<dynamic> categoriesList = json.decode(categoriesJson);
        return categoriesList.cast<String>();
      }
      return [];
    } catch (e) {
      throw const CacheFailure(message: 'Failed to get cached categories');
    }
  }

  @override
  Future<void> cacheCategories(List<String> categories) async {
    try {
      final categoriesJson = json.encode(categories);
      await _sharedPreferences.setString('cached_categories', categoriesJson);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to cache categories');
    }
  }

  @override
  Future<void> removeCachedProduct(int id) async {
    try {
      final products = await getCachedProducts();
      products.removeWhere((product) => product.id == id);
      await cacheProducts(products);
    } catch (e) {
      throw const CacheFailure(message: 'Failed to remove cached product');
    }
  }

  @override
  Future<void> clearProductCache() async {
    try {
      await _sharedPreferences.remove(AppConstants.cachedProductsKey);
      await _sharedPreferences.remove('cached_categories');
    } catch (e) {
      throw const CacheFailure(message: 'Failed to clear product cache');
    }
  }
}
