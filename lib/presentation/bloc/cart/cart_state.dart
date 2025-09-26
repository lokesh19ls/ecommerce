import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item_entity.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final List<CartItemEntity> cartItems;
  final double total;
  final int itemCount;

  const CartLoaded({
    required this.cartItems,
    required this.total,
    required this.itemCount,
  });

  @override
  List<Object> get props => [cartItems, total, itemCount];

  CartLoaded copyWith({
    List<CartItemEntity>? cartItems,
    double? total,
    int? itemCount,
  }) {
    return CartLoaded(
      cartItems: cartItems ?? this.cartItems,
      total: total ?? this.total,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}

class CartEmpty extends CartState {
  const CartEmpty();
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object> get props => [message];
}
