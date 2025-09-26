import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleWishlist;
  final bool isInWishlist;
  final bool isLoading;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onToggleWishlist,
    this.isInWishlist = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Card(
              elevation: 4 + (2 * value),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Expanded(
                      flex: 3,
                      child: Stack(
                        children: [
                          CachedNetworkImage(
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
                              ),
                            ),
                          ),
                          // Wishlist Button
                          if (onToggleWishlist != null)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: isLoading ? null : onToggleWishlist,
                                icon: Icon(
                                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                                  color: isInWishlist
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Product Info
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title and Category
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  style: Theme.of(context).textTheme.titleSmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  product.category,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            // Price and Rating
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      product.rating.toString(),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}