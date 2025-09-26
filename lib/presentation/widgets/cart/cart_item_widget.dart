import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/cart_item.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback? onRemove;
  final void Function(int)? onQuantityChanged;
  final bool isLoading;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    this.onRemove,
    this.onQuantityChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: cartItem.thumbnail,
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
                    cartItem.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Category', // CartItem doesn't have category, using placeholder
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${cartItem.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Total: \$${cartItem.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Quantity Controls
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: isLoading
                          ? null
                          : () => onQuantityChanged?.call(cartItem.quantity - 1),
                      icon: const Icon(Icons.remove),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        cartItem.quantity.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: isLoading
                          ? null
                          : () => onQuantityChanged?.call(cartItem.quantity + 1),
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: isLoading ? null : onRemove,
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
