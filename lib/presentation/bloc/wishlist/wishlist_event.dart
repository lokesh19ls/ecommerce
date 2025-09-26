import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class WishlistLoadRequested extends WishlistEvent {
  const WishlistLoadRequested();
}

class WishlistItemAdded extends WishlistEvent {
  final Product product;

  const WishlistItemAdded({required this.product});

  @override
  List<Object> get props => [product];
}

class WishlistItemRemoved extends WishlistEvent {
  final String wishlistItemId;

  const WishlistItemRemoved({required this.wishlistItemId});

  @override
  List<Object> get props => [wishlistItemId];
}

class WishlistCleared extends WishlistEvent {
  const WishlistCleared();
}

class WishlistItemToggled extends WishlistEvent {
  final Product product;

  const WishlistItemToggled({required this.product});

  @override
  List<Object> get props => [product];
}
