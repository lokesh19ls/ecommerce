import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart.dart';

abstract class CartApiState extends Equatable {
  const CartApiState();

  @override
  List<Object?> get props => [];
}

class CartApiInitial extends CartApiState {
  const CartApiInitial();
}

class CartApiLoading extends CartApiState {
  const CartApiLoading();
}

class CartApiLoaded extends CartApiState {
  final List<Cart> carts;
  final int total;
  final int skip;
  final int limit;

  const CartApiLoaded({
    required this.carts,
    required this.total,
    required this.skip,
    required this.limit,
  });

  @override
  List<Object> get props => [carts, total, skip, limit];
}

class CartApiSingleLoaded extends CartApiState {
  final Cart cart;

  const CartApiSingleLoaded({required this.cart});

  @override
  List<Object> get props => [cart];
}

class CartApiUserCartsLoaded extends CartApiState {
  final List<Cart> carts;
  final int userId;

  const CartApiUserCartsLoaded({
    required this.carts,
    required this.userId,
  });

  @override
  List<Object> get props => [carts, userId];
}

class CartApiDeleted extends CartApiState {
  final Map<String, dynamic> result;

  const CartApiDeleted({required this.result});

  @override
  List<Object> get props => [result];
}

class CartApiError extends CartApiState {
  final String message;

  const CartApiError({required this.message});

  @override
  List<Object> get props => [message];
}
