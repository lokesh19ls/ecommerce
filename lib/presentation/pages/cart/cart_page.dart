import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/dependency_injection.dart';
import '../../../domain/entities/cart_item.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/cart/cart_event.dart';
import '../../bloc/cart/cart_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/cart/cart_item_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const CartLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.cartItems.isNotEmpty) {
                return TextButton(
                  onPressed: () => _showClearCartDialog(),
                  child: const Text('Clear All'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const LoadingWidget(message: 'Loading cart...');
          } else if (state is CartError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<CartBloc>().add(const CartLoadRequested());
              },
            );
          } else if (state is CartEmpty) {
            return EmptyWidget(
              message: 'Your cart is empty',
              icon: Icons.shopping_cart_outlined,
              action: ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Start Shopping'),
              ),
            );
          } else if (state is CartLoaded) {
            return Column(
              children: [
                // Cart Items
                Expanded(
                  child: ListView.builder(
                    itemCount: state.cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItemEntity = state.cartItems[index];
                      final cartItem = CartItem.fromEntity(cartItemEntity);
                      return CartItemWidget(
                        cartItem: cartItem,
                        onRemove: () {
                          context.read<CartBloc>().add(
                            CartItemRemoved(cartItemId: cartItemEntity.id),
                          );
                        },
                        onQuantityChanged: (quantity) {
                          context.read<CartBloc>().add(
                            CartItemQuantityUpdated(
                              cartItemId: cartItemEntity.id,
                              quantity: quantity,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Cart Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Summary Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Items:',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            state.itemCount.toString(),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount:',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${state.total.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Checkout Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Proceed to Checkout',
                          onPressed: () => _showCheckoutDialog(state.total),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const LoadingWidget();
        },
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CartBloc>().add(const CartCleared());
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(double total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Amount: \$${total.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text(
              'This is a demo app. In a real application, this would redirect to a payment gateway.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Simulate successful checkout
              context.read<CartBloc>().add(const CartCleared());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order placed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }
}
