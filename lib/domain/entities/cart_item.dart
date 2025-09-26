import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class CartItem extends Equatable {
  final int id;
  final String title;
  final int price;
  final int quantity;
  final int total;
  final double discountPercentage;
  final int discountedPrice;
  final String thumbnail;

  const CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedPrice,
    required this.thumbnail,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        price,
        quantity,
        total,
        discountPercentage,
        discountedPrice,
        thumbnail,
      ];

  factory CartItem.fromEntity(CartItemEntity entity) {
    final product = entity.product;
    final price = product.price.toInt();
    final quantity = entity.quantity;
    final total = (price * quantity).toInt();
    final discountedPrice = (price * (1 - product.discountPercentage / 100)).toInt();
    
    return CartItem(
      id: int.parse(entity.id),
      title: product.title,
      price: price,
      quantity: quantity,
      total: total,
      discountPercentage: product.discountPercentage,
      discountedPrice: discountedPrice,
      thumbnail: product.thumbnail,
    );
  }
}