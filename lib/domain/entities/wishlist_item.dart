import 'package:equatable/equatable.dart';
import 'product.dart';

class WishlistItem extends Equatable {
  final String id;
  final Product product;
  final DateTime addedAt;

  const WishlistItem({
    required this.id,
    required this.product,
    required this.addedAt,
  });

  @override
  List<Object> get props => [id, product, addedAt];

  WishlistItem copyWith({
    String? id,
    Product? product,
    DateTime? addedAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      product: product ?? this.product,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
