import 'package:equatable/equatable.dart';
import 'product.dart';

class CartItemEntity extends Equatable {
  final String id;
  final Product product;
  final int quantity;
  final DateTime addedAt;

  const CartItemEntity({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  @override
  List<Object> get props => [id, product, quantity, addedAt];

  CartItemEntity copyWith({
    String? id,
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
