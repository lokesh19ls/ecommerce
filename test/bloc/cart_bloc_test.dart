import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ecommerce/domain/entities/cart_item.dart';
import 'package:ecommerce/domain/entities/product.dart';
import 'package:ecommerce/domain/repositories/cart_repository.dart';
import 'package:ecommerce/presentation/bloc/cart/cart_bloc.dart';
import 'package:ecommerce/presentation/bloc/cart/cart_event.dart';
import 'package:ecommerce/presentation/bloc/cart/cart_state.dart';
import 'package:ecommerce/core/errors/failures.dart';

import 'cart_bloc_test.mocks.dart';

@GenerateMocks([CartRepository])
void main() {
  late MockCartRepository mockCartRepository;
  late CartBloc cartBloc;

  setUp(() {
    mockCartRepository = MockCartRepository();
    cartBloc = CartBloc(cartRepository: mockCartRepository);
  });

  tearDown(() {
    cartBloc.close();
  });

  group('CartBloc', () {
    const testProduct = Product(
      id: 1,
      title: 'Test Product',
      price: 10.0,
      description: 'Test Description',
      category: 'Test Category',
      image: 'test_image.jpg',
      rating: Rating(rate: 4.5, count: 100),
    );

    const testCartItem = CartItem(
      id: 'test_id',
      product: testProduct,
      quantity: 1,
      addedAt: null, // This will be set in the test
    );

    group('CartLoadRequested', () {
      blocTest<CartBloc, CartState>(
        'emits [CartLoading, CartLoaded] when cart has items',
        build: () {
          when(mockCartRepository.getCartItems())
              .thenAnswer((_) async => [testCartItem]);
          when(mockCartRepository.getCartTotal())
              .thenAnswer((_) async => 10.0);
          when(mockCartRepository.getCartItemCount())
              .thenAnswer((_) async => 1);
          return cartBloc;
        },
        act: (bloc) => bloc.add(const CartLoadRequested()),
        expect: () => [
          const CartLoading(),
          const CartLoaded(
            cartItems: [testCartItem],
            total: 10.0,
            itemCount: 1,
          ),
        ],
        verify: (_) {
          verify(mockCartRepository.getCartItems()).called(1);
          verify(mockCartRepository.getCartTotal()).called(1);
          verify(mockCartRepository.getCartItemCount()).called(1);
        },
      );

      blocTest<CartBloc, CartState>(
        'emits [CartLoading, CartEmpty] when cart is empty',
        build: () {
          when(mockCartRepository.getCartItems())
              .thenAnswer((_) async => []);
          when(mockCartRepository.getCartTotal())
              .thenAnswer((_) async => 0.0);
          when(mockCartRepository.getCartItemCount())
              .thenAnswer((_) async => 0);
          return cartBloc;
        },
        act: (bloc) => bloc.add(const CartLoadRequested()),
        expect: () => [
          const CartLoading(),
          const CartEmpty(),
        ],
        verify: (_) {
          verify(mockCartRepository.getCartItems()).called(1);
          verify(mockCartRepository.getCartTotal()).called(1);
          verify(mockCartRepository.getCartItemCount()).called(1);
        },
      );

      blocTest<CartBloc, CartState>(
        'emits [CartLoading, CartError] when repository throws error',
        build: () {
          when(mockCartRepository.getCartItems())
              .thenThrow(const CacheFailure(message: 'Failed to load cart'));
          return cartBloc;
        },
        act: (bloc) => bloc.add(const CartLoadRequested()),
        expect: () => [
          const CartLoading(),
          const CartError(message: 'Failed to load cart'),
        ],
        verify: (_) {
          verify(mockCartRepository.getCartItems()).called(1);
        },
      );
    });

    group('CartItemAdded', () {
      blocTest<CartBloc, CartState>(
        'adds item to cart and reloads cart',
        build: () {
          when(mockCartRepository.addToCart(any))
              .thenAnswer((_) async {});
          when(mockCartRepository.getCartItems())
              .thenAnswer((_) async => [testCartItem]);
          when(mockCartRepository.getCartTotal())
              .thenAnswer((_) async => 10.0);
          when(mockCartRepository.getCartItemCount())
              .thenAnswer((_) async => 1);
          return cartBloc;
        },
        act: (bloc) => bloc.add(const CartItemAdded(product: testProduct)),
        expect: () => [
          const CartLoading(),
          const CartLoaded(
            cartItems: [testCartItem],
            total: 10.0,
            itemCount: 1,
          ),
        ],
        verify: (_) {
          verify(mockCartRepository.addToCart(any)).called(1);
          verify(mockCartRepository.getCartItems()).called(1);
          verify(mockCartRepository.getCartTotal()).called(1);
          verify(mockCartRepository.getCartItemCount()).called(1);
        },
      );
    });

    group('CartItemRemoved', () {
      blocTest<CartBloc, CartState>(
        'removes item from cart and reloads cart',
        build: () {
          when(mockCartRepository.removeFromCart('test_id'))
              .thenAnswer((_) async {});
          when(mockCartRepository.getCartItems())
              .thenAnswer((_) async => []);
          when(mockCartRepository.getCartTotal())
              .thenAnswer((_) async => 0.0);
          when(mockCartRepository.getCartItemCount())
              .thenAnswer((_) async => 0);
          return cartBloc;
        },
        act: (bloc) => bloc.add(const CartItemRemoved(cartItemId: 'test_id')),
        expect: () => [
          const CartLoading(),
          const CartEmpty(),
        ],
        verify: (_) {
          verify(mockCartRepository.removeFromCart('test_id')).called(1);
          verify(mockCartRepository.getCartItems()).called(1);
          verify(mockCartRepository.getCartTotal()).called(1);
          verify(mockCartRepository.getCartItemCount()).called(1);
        },
      );
    });

    group('CartCleared', () {
      blocTest<CartBloc, CartState>(
        'clears cart and emits CartEmpty',
        build: () {
          when(mockCartRepository.clearCart())
              .thenAnswer((_) async {});
          return cartBloc;
        },
        act: (bloc) => bloc.add(const CartCleared()),
        expect: () => [
          const CartEmpty(),
        ],
        verify: (_) {
          verify(mockCartRepository.clearCart()).called(1);
        },
      );
    });
  });
}
