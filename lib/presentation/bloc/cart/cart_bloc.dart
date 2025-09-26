import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/repositories/local_cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final LocalCartRepository _cartRepository;

  CartBloc({
    required LocalCartRepository cartRepository,
  })  : _cartRepository = cartRepository,
        super(const CartInitial()) {
    on<CartLoadRequested>(_onCartLoadRequested);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartItemRemoved>(_onCartItemRemoved);
    on<CartItemQuantityUpdated>(_onCartItemQuantityUpdated);
    on<CartCleared>(_onCartCleared);
  }

  Future<void> _onCartLoadRequested(
    CartLoadRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    
    try {
      final cartItems = await _cartRepository.getCartItems();
      final total = await _cartRepository.getCartTotal();
      final itemCount = await _cartRepository.getCartItemCount();
      
      if (cartItems.isEmpty) {
        emit(const CartEmpty());
      } else {
        emit(CartLoaded(
          cartItems: cartItems,
          total: total,
          itemCount: itemCount,
        ));
      }
    } on Failure catch (failure) {
      emit(CartError(message: failure.message));
    } catch (e) {
      emit(const CartError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _cartRepository.addCartItem(event.product, event.quantity);
      
      // Reload cart to get updated state
      add(const CartLoadRequested());
    } on Failure catch (failure) {
      emit(CartError(message: failure.message));
    } catch (e) {
      emit(const CartError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _cartRepository.removeCartItem(event.cartItemId);
      
      // Reload cart to get updated state
      add(const CartLoadRequested());
    } on Failure catch (failure) {
      emit(CartError(message: failure.message));
    } catch (e) {
      emit(const CartError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onCartItemQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _cartRepository.updateCartItemQuantity(
        event.cartItemId,
        event.quantity,
      );
      
      // Reload cart to get updated state
      add(const CartLoadRequested());
    } on Failure catch (failure) {
      emit(CartError(message: failure.message));
    } catch (e) {
      emit(const CartError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onCartCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _cartRepository.clearCart();
      emit(const CartEmpty());
    } on Failure catch (failure) {
      emit(CartError(message: failure.message));
    } catch (e) {
      emit(const CartError(message: 'An unexpected error occurred'));
    }
  }
}
