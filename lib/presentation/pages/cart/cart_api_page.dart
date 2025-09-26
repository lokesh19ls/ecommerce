import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/dependency_injection.dart';
import '../../bloc/cart/cart_api_bloc.dart';
import '../../bloc/cart/cart_api_event.dart';
import '../../bloc/cart/cart_api_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class CartApiPage extends StatefulWidget {
  const CartApiPage({super.key});

  @override
  State<CartApiPage> createState() => _CartApiPageState();
}

class _CartApiPageState extends State<CartApiPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    
    // Load carts when page initializes
    context.read<CartApiBloc>().add(const CartApiLoadRequested());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart API Demo'),
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
          IconButton(
            onPressed: () {
              _showAddCartDialog();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: BlocBuilder<CartApiBloc, CartApiState>(
              builder: (context, state) {
                if (state is CartApiLoading) {
                  return const LoadingWidget(message: 'Loading carts...');
                } else if (state is CartApiError) {
                  return CustomErrorWidget(
                    message: state.message,
                    onRetry: () {
                      context.read<CartApiBloc>().add(const CartApiLoadRequested());
                    },
                  );
                } else if (state is CartApiLoaded) {
                  return _buildCartsList(state.carts);
                } else if (state is CartApiSingleLoaded) {
                  return _buildSingleCart(state.cart);
                } else if (state is CartApiUserCartsLoaded) {
                  return _buildUserCarts(state.carts, state.userId);
                } else if (state is CartApiDeleted) {
                  return _buildDeletedCart(state.result);
                }
                
                return const Center(
                  child: Text('No data available'),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartsList(List<dynamic> carts) {
    return Column(
      children: [
        // Header with stats
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${carts.length} Carts Available',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showUserCartsDialog();
                },
                icon: const Icon(Icons.person),
                label: const Text('User Carts'),
              ),
            ],
          ),
        ),
        
        // Carts list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: carts.length,
            itemBuilder: (context, index) {
              final cart = carts[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildCartCard(cart),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartCard(dynamic cart) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.read<CartApiBloc>().add(
            CartApiLoadByIdRequested(cartId: cart.id),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cart #${cart.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'User ${cart.userId}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Products',
                      '${cart.totalProducts}',
                      Icons.shopping_bag,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Quantity',
                      '${cart.totalQuantity}',
                      Icons.inventory,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Total',
                      '\$${cart.total}',
                      Icons.attach_money,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<CartApiBloc>().add(
                          CartApiLoadByIdRequested(cartId: cart.id),
                        );
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showDeleteCartDialog(cart.id);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleCart(dynamic cart) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cart header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cart #${cart.id}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('User ID: ${cart.userId}'),
                  Text('Total Products: ${cart.totalProducts}'),
                  Text('Total Quantity: ${cart.totalQuantity}'),
                  Text('Total: \$${cart.total}'),
                  Text('Discounted Total: \$${cart.discountedTotal}'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Products list
          Text(
            'Products (${cart.products.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          ...cart.products.map((product) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(product.thumbnail),
              ),
              title: Text(product.title),
              subtitle: Text('Qty: ${product.quantity} • \$${product.price} each'),
              trailing: Text(
                '\$${product.total}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          )).toList(),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<CartApiBloc>().add(const CartApiLoadRequested());
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Carts'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showUpdateCartDialog(cart);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Update Cart'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCarts(List<dynamic> carts, int userId) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Carts for User $userId (${carts.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: carts.length,
            itemBuilder: (context, index) {
              final cart = carts[index];
              return _buildCartCard(cart);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeletedCart(Map<String, dynamic> result) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Cart Deleted',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('Cart ID: ${result['id']}'),
          Text('Deleted: ${result['isDeleted']}'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<CartApiBloc>().add(const CartApiLoadRequested());
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Carts'),
          ),
        ],
      ),
    );
  }

  void _showAddCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Cart'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // Handle user ID input
              },
            ),
            const SizedBox(height: 16),
            const Text('Products will be added automatically for demo'),
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
              // Add cart with sample data
              context.read<CartApiBloc>().add(
                const CartApiAddRequested(
                  userId: 1,
                  products: [
                    {'id': 1, 'quantity': 2},
                    {'id': 2, 'quantity': 1},
                  ],
                ),
              );
            },
            child: const Text('Add Cart'),
          ),
        ],
      ),
    );
  }

  void _showUserCartsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get User Carts'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'User ID',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            // Handle user ID input
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CartApiBloc>().add(
                const CartApiLoadByUserRequested(userId: 1),
              );
            },
            child: const Text('Get Carts'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCartDialog(int cartId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cart'),
        content: Text('Are you sure you want to delete cart #$cartId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CartApiBloc>().add(
                CartApiDeleteRequested(cartId: cartId),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUpdateCartDialog(dynamic cart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Cart'),
        content: const Text('This will add a new product to the cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CartApiBloc>().add(
                CartApiUpdateRequested(
                  cartId: cart.id,
                  userId: cart.userId,
                  products: [
                    {'id': 3, 'quantity': 1},
                  ],
                  merge: true,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
