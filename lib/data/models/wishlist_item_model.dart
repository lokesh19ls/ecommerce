import 'package:equatable/equatable.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../domain/entities/product.dart';
import 'product_model.dart';

class WishlistItemModel extends WishlistItem {
  const WishlistItemModel({
    required super.id,
    required super.product,
    required super.addedAt,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': (product as ProductModel).toJson(),
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory WishlistItemModel.fromEntity(WishlistItem wishlistItem) {
    return WishlistItemModel(
      id: wishlistItem.id,
      product: wishlistItem.product,
      addedAt: wishlistItem.addedAt,
    );
  }

  @override
  WishlistItemModel copyWith({
    String? id,
    Product? product,
    DateTime? addedAt,
  }) {
    return WishlistItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
