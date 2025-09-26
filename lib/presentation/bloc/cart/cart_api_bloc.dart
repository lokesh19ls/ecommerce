import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/cart.dart';
import '../../../domain/repositories/cart_repository.dart';
import '../../../data/models/cart_api_model.dart';
import 'cart_api_event.dart';
import 'cart_api_state.dart';

class CartApiBloc extends Bloc<CartApiEvent, CartApiState> {
  final CartRepository _cartRepository;

  CartApiBloc({
    required CartRepository cartRepository,
  })  : _cartRepository = cartRepository,
        super(const CartApiInitial()) {
    on<CartApiLoadRequested>(_onCartApiLoadRequested);
    on<CartApiLoadByIdRequested>(_onCartApiLoadByIdRequested);
    on<CartApiLoadByUserRequested>(_onCartApiLoadByUserRequested);
    on<CartApiAddRequested>(_onCartApiAddRequested);
    on<CartApiUpdateRequested>(_onCartApiUpdateRequested);
    on<CartApiDeleteRequested>(_onCartApiDeleteRequested);
  }

  Future<void> _onCartApiLoadRequested(
    CartApiLoadRequested event,
    Emitter<CartApiState> emit,
  ) async {
    emit(const CartApiLoading());
    
    try {
      print('DEBUG: CartApiBloc - Loading all carts...');
      final result = await _cartRepository.getCarts(
        limit: event.limit,
        skip: event.skip,
      );
      
      final carts = (result['carts'] as List<dynamic>)
          .map((cartJson) => CartApiModel.fromJson(cartJson as Map<String, dynamic>).toEntity())
          .toList();
      
      emit(CartApiLoaded(
        carts: carts,
        total: result['total'] as int,
        skip: result['skip'] as int,
        limit: result['limit'] as int,
      ));
      
      print('DEBUG: CartApiBloc - Loaded ${carts.length} carts');
    } on Failure catch (failure) {
      emit(CartApiError(message: failure.message));
    } catch (e) {
      emit(const CartApiError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onCartApiLoadByIdRequested(
    CartApiLoadByIdRequested event,
    Emitter<CartApiState> emit,
  ) async {
    emit(const CartApiLoading());
    
    try {
      print('DEBUG: CartApiBloc - Loading cart ${event.cartId}...');
      final cart = await _cartRepository.getCart(event.cartId);
      
      emit(CartApiSingleLoaded(cart: cart));
      
      print('DEBUG: CartApiBloc - Loaded cart ${event.cartId}');
    } on Failure catch (failure) {
      emit(CartApiError(message: failure.message));
    } catch (e) {
      emit(const CartApiError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onCartApiLoadByUserRequested(
    CartApiLoadByUserRequested event,
    Emitter<CartApiState> emit,
  ) async {
    emit(const CartApiLoading());
    
    try {
      print('DEBUG: CartApiBloc - Loading carts for user ${event.userId}...');
      final result = await _cartRepository.getCartsByUser(event.userId);
      
      final carts = (result['carts'] as List<dynamic>)
          .map((cartJson) => CartApiModel.fromJson(cartJson as Map<String, dynamic>).toEntity())
          .toList();
      
      emit(CartApiUserCartsLoaded(
        carts: carts,
        userId: event.userId,
      ));
      
      print('DEBUG: CartApiBloc - Loaded ${carts.length} carts for user ${event.userId}');
    } on Failure catch (failure) {
      emit(CartApiError(message: failure.message));
    } catch (e) {
      emit(const CartApiError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onCartApiAddRequested(
    CartApiAddRequested event,
    Emitter<CartApiState> emit,
  ) async {
    emit(const CartApiLoading());
    
    try {
      print('DEBUG: CartApiBloc - Adding cart for user ${event.userId}...');
      final cart = await _cartRepository.addCart(
        userId: event.userId,
        products: event.products,
      );
      
      emit(CartApiSingleLoaded(cart: cart));
      
      print('DEBUG: CartApiBloc - Added cart ${cart.id}');
    } on Failure catch (failure) {
      emit(CartApiError(message: failure.message));
    } catch (e) {
      emit(const CartApiError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onCartApiUpdateRequested(
    CartApiUpdateRequested event,
    Emitter<CartApiState> emit,
  ) async {
    emit(const CartApiLoading());
    
    try {
      print('DEBUG: CartApiBloc - Updating cart ${event.cartId}...');
      final cart = await _cartRepository.updateCart(
        cartId: event.cartId,
        userId: event.userId,
        products: event.products,
        merge: event.merge,
      );
      
      emit(CartApiSingleLoaded(cart: cart));
      
      print('DEBUG: CartApiBloc - Updated cart ${event.cartId}');
    } on Failure catch (failure) {
      emit(CartApiError(message: failure.message));
    } catch (e) {
      emit(const CartApiError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onCartApiDeleteRequested(
    CartApiDeleteRequested event,
    Emitter<CartApiState> emit,
  ) async {
    emit(const CartApiLoading());
    
    try {
      print('DEBUG: CartApiBloc - Deleting cart ${event.cartId}...');
      final result = await _cartRepository.deleteCart(event.cartId);
      
      emit(CartApiDeleted(result: result));
      
      print('DEBUG: CartApiBloc - Deleted cart ${event.cartId}');
    } on Failure catch (failure) {
      emit(CartApiError(message: failure.message));
    } catch (e) {
      emit(const CartApiError(message: 'An unexpected error occurred'));
    }
  }
}
