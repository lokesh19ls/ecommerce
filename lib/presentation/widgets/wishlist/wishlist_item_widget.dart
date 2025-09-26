import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/wishlist_item.dart';

class WishlistItemWidget extends StatelessWidget {
  final WishlistItem wishlistItem;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onAddToCart;
  final bool isLoading;

  const WishlistItemWidget({
    super.key,
    required this.wishlistItem,
    this.onTap,
    this.onRemove,
    this.onAddToCart,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: wishlistItem.product.thumbnail,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wishlistItem.product.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wishlistItem.product.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${wishlistItem.product.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              wishlistItem.product.rating.toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              Column(
                children: [
                  if (onAddToCart != null)
                    IconButton(
                      onPressed: isLoading ? null : onAddToCart,
                      icon: const Icon(Icons.add_shopping_cart),
                      tooltip: 'Add to Cart',
                    ),
                  IconButton(
                    onPressed: isLoading ? null : onRemove,
                    icon: const Icon(Icons.favorite),
                    color: Colors.red,
                    tooltip: 'Remove from Wishlist',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
