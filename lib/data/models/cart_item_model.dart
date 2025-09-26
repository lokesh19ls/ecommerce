import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/product.dart';
import 'product_model.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.product,
    required super.quantity,
    required super.addedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'].toString(),
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': (product as ProductModel).toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CartItemModel.fromEntity(CartItemEntity cartItem) {
    return CartItemModel(
      id: cartItem.id,
      product: cartItem.product,
      quantity: cartItem.quantity,
      addedAt: cartItem.addedAt,
    );
  }

  @override
  CartItemModel copyWith({
    String? id,
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
