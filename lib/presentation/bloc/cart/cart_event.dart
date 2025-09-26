import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartLoadRequested extends CartEvent {
  const CartLoadRequested();
}

class CartItemAdded extends CartEvent {
  final Product product;
  final int quantity;

  const CartItemAdded({
    required this.product,
    this.quantity = 1,
  });

  @override
  List<Object> get props => [product, quantity];
}

class CartItemRemoved extends CartEvent {
  final String cartItemId;

  const CartItemRemoved({required this.cartItemId});

  @override
  List<Object> get props => [cartItemId];
}

class CartItemQuantityUpdated extends CartEvent {
  final String cartItemId;
  final int quantity;

  const CartItemQuantityUpdated({
    required this.cartItemId,
    required this.quantity,
  });

  @override
  List<Object> get props => [cartItemId, quantity];
}

class CartCleared extends CartEvent {
  const CartCleared();
}
