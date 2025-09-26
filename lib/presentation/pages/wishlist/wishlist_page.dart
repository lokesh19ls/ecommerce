import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/dependency_injection.dart';
import '../../bloc/wishlist/wishlist_bloc.dart';
import '../../bloc/wishlist/wishlist_event.dart';
import '../../bloc/wishlist/wishlist_state.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/cart/cart_event.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/wishlist/wishlist_item_widget.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    context.read<WishlistBloc>().add(const WishlistLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
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
          BlocBuilder<WishlistBloc, WishlistState>(
            builder: (context, state) {
              if (state is WishlistLoaded && state.wishlistItems.isNotEmpty) {
                return TextButton(
                  onPressed: () => _showClearWishlistDialog(),
                  child: const Text('Clear All'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<WishlistBloc, WishlistState>(
        builder: (context, state) {
          if (state is WishlistLoading) {
            return const LoadingWidget(message: 'Loading wishlist...');
          } else if (state is WishlistError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<WishlistBloc>().add(const WishlistLoadRequested());
              },
            );
          } else if (state is WishlistEmpty) {
            return EmptyWidget(
              message: 'Your wishlist is empty',
              icon: Icons.favorite_border,
              action: ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Start Shopping'),
              ),
            );
          } else if (state is WishlistLoaded) {
            return ListView.builder(
              itemCount: state.wishlistItems.length,
              itemBuilder: (context, index) {
                final wishlistItem = state.wishlistItems[index];
                return WishlistItemWidget(
                  wishlistItem: wishlistItem,
                  onTap: () {
                    context.go('/product/${wishlistItem.product.id}');
                  },
                  onRemove: () {
                    context.read<WishlistBloc>().add(
                      WishlistItemRemoved(wishlistItemId: wishlistItem.id),
                    );
                  },
                  onAddToCart: () {
                    context.read<CartBloc>().add(
                      CartItemAdded(product: wishlistItem.product),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${wishlistItem.product.title} added to cart'),
                        action: SnackBarAction(
                          label: 'View Cart',
                          onPressed: () => context.go('/cart'),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const LoadingWidget();
        },
      ),
    );
  }

  void _showClearWishlistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text('Are you sure you want to remove all items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<WishlistBloc>().add(const WishlistCleared());
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
