import 'package:equatable/equatable.dart';
import 'cart_item.dart';

class Cart extends Equatable {
  final int id;
  final List<CartItem> products;
  final int total;
  final int discountedTotal;
  final int userId;
  final int totalProducts;
  final int totalQuantity;

  const Cart({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  @override
  List<Object?> get props => [
        id,
        products,
        total,
        discountedTotal,
        userId,
        totalProducts,
        totalQuantity,
      ];
}
