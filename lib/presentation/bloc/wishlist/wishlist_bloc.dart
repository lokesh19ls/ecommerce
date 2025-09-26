import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/wishlist_item.dart';
import '../../../domain/repositories/wishlist_repository.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository _wishlistRepository;
  final Uuid _uuid = const Uuid();

  WishlistBloc({
    required WishlistRepository wishlistRepository,
  })  : _wishlistRepository = wishlistRepository,
        super(const WishlistInitial()) {
    on<WishlistLoadRequested>(_onWishlistLoadRequested);
    on<WishlistItemAdded>(_onWishlistItemAdded);
    on<WishlistItemRemoved>(_onWishlistItemRemoved);
    on<WishlistCleared>(_onWishlistCleared);
    on<WishlistItemToggled>(_onWishlistItemToggled);
  }

  Future<void> _onWishlistLoadRequested(
    WishlistLoadRequested event,
    Emitter<WishlistState> emit,
  ) async {
    emit(const WishlistLoading());
    
    try {
      final wishlistItems = await _wishlistRepository.getWishlistItems();
      
      if (wishlistItems.isEmpty) {
        emit(const WishlistEmpty());
      } else {
        emit(WishlistLoaded(wishlistItems: wishlistItems));
      }
    } on Failure catch (failure) {
      emit(WishlistError(message: failure.message));
    } catch (e) {
      emit(const WishlistError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onWishlistItemAdded(
    WishlistItemAdded event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      final wishlistItem = WishlistItem(
        id: _uuid.v4(),
        product: event.product,
        addedAt: DateTime.now(),
      );
      
      await _wishlistRepository.addToWishlist(wishlistItem);
      
      // Reload wishlist to get updated state
      add(const WishlistLoadRequested());
    } on Failure catch (failure) {
      emit(WishlistError(message: failure.message));
    } catch (e) {
      emit(const WishlistError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onWishlistItemRemoved(
    WishlistItemRemoved event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      await _wishlistRepository.removeFromWishlist(event.wishlistItemId);
      
      // Reload wishlist to get updated state
      add(const WishlistLoadRequested());
    } on Failure catch (failure) {
      emit(WishlistError(message: failure.message));
    } catch (e) {
      emit(const WishlistError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onWishlistCleared(
    WishlistCleared event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      await _wishlistRepository.clearWishlist();
      emit(const WishlistEmpty());
    } on Failure catch (failure) {
      emit(WishlistError(message: failure.message));
    } catch (e) {
      emit(const WishlistError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onWishlistItemToggled(
    WishlistItemToggled event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      final isInWishlist = await _wishlistRepository.isProductInWishlist(event.product.id);
      
      if (isInWishlist) {
        // Find and remove the item
        final wishlistItems = await _wishlistRepository.getWishlistItems();
        final itemToRemove = wishlistItems.firstWhere(
          (item) => item.product.id == event.product.id,
        );
        await _wishlistRepository.removeFromWishlist(itemToRemove.id);
      } else {
        // Add the item
        final wishlistItem = WishlistItem(
          id: _uuid.v4(),
          product: event.product,
          addedAt: DateTime.now(),
        );
        await _wishlistRepository.addToWishlist(wishlistItem);
      }
      
      // Reload wishlist to get updated state
      add(const WishlistLoadRequested());
    } on Failure catch (failure) {
      emit(WishlistError(message: failure.message));
    } catch (e) {
      emit(const WishlistError(message: 'An unexpected error occurred'));
    }
  }
}
