import 'package:equatable/equatable.dart';

abstract class CartApiEvent extends Equatable {
  const CartApiEvent();

  @override
  List<Object?> get props => [];
}

class CartApiLoadRequested extends CartApiEvent {
  final int? limit;
  final int? skip;

  const CartApiLoadRequested({
    this.limit,
    this.skip,
  });

  @override
  List<Object?> get props => [limit, skip];
}

class CartApiLoadByIdRequested extends CartApiEvent {
  final int cartId;

  const CartApiLoadByIdRequested({required this.cartId});

  @override
  List<Object> get props => [cartId];
}

class CartApiLoadByUserRequested extends CartApiEvent {
  final int userId;

  const CartApiLoadByUserRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class CartApiAddRequested extends CartApiEvent {
  final int userId;
  final List<Map<String, dynamic>> products;

  const CartApiAddRequested({
    required this.userId,
    required this.products,
  });

  @override
  List<Object> get props => [userId, products];
}

class CartApiUpdateRequested extends CartApiEvent {
  final int cartId;
  final int userId;
  final List<Map<String, dynamic>> products;
  final bool merge;

  const CartApiUpdateRequested({
    required this.cartId,
    required this.userId,
    required this.products,
    this.merge = false,
  });

  @override
  List<Object> get props => [cartId, userId, products, merge];
}

class CartApiDeleteRequested extends CartApiEvent {
  final int cartId;

  const CartApiDeleteRequested({required this.cartId});

  @override
  List<Object> get props => [cartId];
}
