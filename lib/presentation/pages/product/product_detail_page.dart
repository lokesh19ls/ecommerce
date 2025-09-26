import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/dependency_injection.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/cart/cart_event.dart';
import '../../bloc/wishlist/wishlist_bloc.dart';
import '../../bloc/wishlist/wishlist_event.dart';
import '../../bloc/wishlist/wishlist_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_button.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductDetailRequested(productId: widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Check if we can pop, otherwise go to home
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
              bool isInWishlist = false;
              if (state is WishlistLoaded) {
                isInWishlist = state.wishlistItems
                    .any((item) => item.product.id == widget.productId);
              }

              return IconButton(
                onPressed: () {
                  // We need to get the product from the current state
                  final productState = context.read<ProductBloc>().state;
                  if (productState is ProductDetailLoaded) {
                    context.read<WishlistBloc>().add(
                      WishlistItemToggled(product: productState.product),
                    );
                  }
                },
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : null,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const LoadingWidget(message: 'Loading product details...');
          } else if (state is ProductError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<ProductBloc>().add(
                  ProductDetailRequested(productId: widget.productId),
                );
              },
            );
          } else if (state is ProductDetailLoaded) {
            final product = state.product;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: product.thumbnail,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                  // Product Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          product.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            product.category,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Price and Rating
                        Row(
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${product.rating} (${product.reviews.length})',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Description
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        // Quantity Selector
                        Text(
                          'Quantity',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _quantity > 1 ? () {
                                setState(() {
                                  _quantity--;
                                });
                              } : null,
                              icon: const Icon(Icons.remove),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                _quantity.toString(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                              icon: const Icon(Icons.add),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Add to Cart Button
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Add to Cart - \$${(product.price * _quantity).toStringAsFixed(2)}',
                            onPressed: () {
                              context.read<CartBloc>().add(
                                CartItemAdded(
                                  product: product,
                                  quantity: _quantity,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.title} added to cart'),
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    onPressed: () {
                                      Navigator.of(context).pushNamed('/cart');
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const LoadingWidget();
        },
      ),
    );
  }
}
