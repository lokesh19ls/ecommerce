import 'package:equatable/equatable.dart';
import '../../../domain/entities/wishlist_item.dart';

abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {
  const WishlistInitial();
}

class WishlistLoading extends WishlistState {
  const WishlistLoading();
}

class WishlistLoaded extends WishlistState {
  final List<WishlistItem> wishlistItems;

  const WishlistLoaded({required this.wishlistItems});

  @override
  List<Object> get props => [wishlistItems];

  WishlistLoaded copyWith({
    List<WishlistItem>? wishlistItems,
  }) {
    return WishlistLoaded(
      wishlistItems: wishlistItems ?? this.wishlistItems,
    );
  }
}

class WishlistEmpty extends WishlistState {
  const WishlistEmpty();
}

class WishlistError extends WishlistState {
  final String message;

  const WishlistError({required this.message});

  @override
  List<Object> get props => [message];
}
