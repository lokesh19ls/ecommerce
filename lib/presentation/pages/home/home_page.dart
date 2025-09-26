import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../core/utils/dependency_injection.dart';
import '../../../domain/entities/product.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/cart/cart_event.dart';
import '../../bloc/cart/cart_state.dart';
import '../../bloc/wishlist/wishlist_bloc.dart';
import '../../bloc/wishlist/wishlist_event.dart';
import '../../bloc/wishlist/wishlist_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/product/product_card.dart';
import '../product/product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final TextEditingController _searchController = TextEditingController();
  List<String> _lastCategories = [];

  @override
  void initState() {
    super.initState();
    // Load products when the page initializes
    context.read<ProductBloc>().add(const ProductLoadRequested());
    context.read<CartBloc>().add(const CartLoadRequested());
    context.read<WishlistBloc>().add(const WishlistLoadRequested());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.go('/orders');
              break;
            case 2:
              context.go('/cart');
              break;
            case 3:
              context.go('/wishlist');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('E-Commerce'),
        actions: [
          // Theme Toggle
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              final isDarkMode = state is ThemeLoaded ? state.isDarkMode : false;
              return IconButton(
                onPressed: () {
                  context.read<ThemeBloc>().add(const ThemeToggled());
                },
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              );
            },
          ),
          // Cart Icon
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              final itemCount = state is CartLoaded ? state.itemCount : 0;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () => context.go('/cart'),
                    icon: const Icon(Icons.shopping_cart),
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          itemCount.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Profile Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.go('/profile');
                  break;
                case 'wishlist':
                  context.go('/wishlist');
                  break;
                case 'settings':
                  context.go('/settings');
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'wishlist',
                child: Row(
                  children: [
                    Icon(Icons.favorite),
                    SizedBox(width: 8),
                    Text('Wishlist'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ProductBloc>().add(const ProductLoadRequested());
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      context.read<ProductBloc>().add(const ProductLoadRequested());
                    } else {
                      context.read<ProductBloc>().add(ProductSearchRequested(query: value));
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Filter Row
                Row(
                  children: [
                    // Category Filter
                    Expanded(
                      child: BlocBuilder<ProductBloc, ProductState>(
                        buildWhen: (previous, current) {
                          // Force rebuild when categories or selected category changes
                          if (previous is ProductLoaded && current is ProductLoaded) {
                            return previous.categories != current.categories ||
                                   previous.selectedCategory != current.selectedCategory;
                          }
                          return true;
                        },
                        builder: (context, state) {
                          final rawCategories = state is ProductLoaded ? state.categories : <String>[];
                          final categories = rawCategories.toSet().toList()..sort();
                          
                          // Only update if categories have actually changed
                          if (categories.toString() != _lastCategories.toString()) {
                            _lastCategories = List.from(categories);
                            // Reset selected category if it's no longer valid
                            final currentSelectedCategory = state is ProductLoaded ? state.selectedCategory : null;
                            if (currentSelectedCategory != null && !categories.contains(currentSelectedCategory)) {
                              // Trigger a filter change to reset the category
                              context.read<ProductBloc>().add(
                                ProductFilterChanged(category: null),
                              );
                            }
                          }
                          
                          print('DEBUG: Raw categories: $rawCategories');
                          print('DEBUG: Deduplicated categories: $categories');
                          // Get the current selected category from BLoC state
                          final currentSelectedCategory = state is ProductLoaded ? state.selectedCategory : null;
                          
                          return DropdownButtonFormField<String>(
                            key: ValueKey('category_dropdown_${categories.length}'),
                            value: currentSelectedCategory != null && categories.contains(currentSelectedCategory) ? currentSelectedCategory : null,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              isDense: true,
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All Categories'),
                              ),
                              ...categories.asMap().entries.map(
                                (entry) => DropdownMenuItem(
                                  value: entry.value,
                                  child: Text(entry.value),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              // Debug logging for category selection
                              if (value != null) {
                                final currentState = context.read<ProductBloc>().state;
                                if (currentState is ProductLoaded) {
                                  final productsInCategory = currentState.products
                                      .where((product) => product.category.toLowerCase() == value.toLowerCase())
                                      .length;
                                  print('DEBUG: Selected category: "$value"');
                                  print('DEBUG: Products in category "$value": $productsInCategory');
                                } else {
                                  print('DEBUG: Selected category: "$value" (products not loaded yet)');
                                }
                              } else {
                                print('DEBUG: Selected category: "All Categories"');
                              }
                              
                              context.read<ProductBloc>().add(
                                ProductFilterChanged(category: value),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Sort Filter
                    Expanded(
                      child: BlocBuilder<ProductBloc, ProductState>(
                        buildWhen: (previous, current) {
                          // Force rebuild when sort changes
                          if (previous is ProductLoaded && current is ProductLoaded) {
                            return previous.selectedSort != current.selectedSort;
                          }
                          return true;
                        },
                        builder: (context, state) {
                          final currentSelectedSort = state is ProductLoaded ? state.selectedSort : null;
                          
                          return DropdownButtonFormField<String>(
                            value: currentSelectedSort,
                        decoration: const InputDecoration(
                          labelText: 'Sort',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Default'),
                          ),
                          DropdownMenuItem(
                            value: 'title',
                            child: Text('Name: A to Z'),
                          ),
                          DropdownMenuItem(
                            value: 'price_low',
                            child: Text('Price: Low to High'),
                          ),
                          DropdownMenuItem(
                            value: 'price_high',
                            child: Text('Price: High to Low'),
                          ),
                          DropdownMenuItem(
                            value: 'rating',
                            child: Text('Rating: High to Low'),
                          ),
                          DropdownMenuItem(
                            value: 'stock',
                            child: Text('Stock: High to Low'),
                          ),
                          DropdownMenuItem(
                            value: 'discount',
                            child: Text('Best Discounts'),
                          ),
                        ],
                        onChanged: (value) {
                          context.read<ProductBloc>().add(
                            ProductFilterChanged(sort: value),
                          );
                        },
                      );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Products List
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              buildWhen: (previous, current) {
                // Force rebuild when category or sort changes
                if (previous is ProductLoaded && current is ProductLoaded) {
                  return previous.selectedCategory != current.selectedCategory ||
                         previous.selectedSort != current.selectedSort ||
                         previous.products != current.products;
                }
                return true;
              },
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const LoadingWidget(message: 'Loading products...');
                } else if (state is ProductError) {
                  return CustomErrorWidget(
                    message: state.message,
                    onRetry: () {
                      context.read<ProductBloc>().add(const ProductLoadRequested());
                    },
                  );
        } else if (state is ProductLoaded) {
          // Filter products based on selected category
          List<Product> filteredProducts = state.products;
          
          print('DEBUG: UI - Current state.selectedCategory: ${state.selectedCategory}');
          print('DEBUG: UI - Current state.isSearching: ${state.isSearching}');
          print('DEBUG: UI - Total products available: ${state.products.length}');
          print('DEBUG: UI - State type: ${state.runtimeType}');
          print('DEBUG: UI - State hash: ${state.hashCode}');

          if (state.selectedCategory != null && !state.isSearching) {
            filteredProducts = state.products
                .where((product) => product.category.toLowerCase() == state.selectedCategory!.toLowerCase())
                .toList();
            print('DEBUG: UI - Filtering products for category "${state.selectedCategory}": ${filteredProducts.length} out of ${state.products.length}');
          } else {
            print('DEBUG: UI - Showing all products (no category filter)');
          }
                  
                  if (filteredProducts.isEmpty) {
                    String message;
                    IconData icon;
                    Widget? action;
                    
                    if (state.isSearching) {
                      message = 'No products found for "${state.searchQuery}"';
                      icon = Icons.search_off;
                      action = ElevatedButton(
                        onPressed: () {
                          _searchController.clear();
                          context.read<ProductBloc>().add(const ProductLoadRequested());
                        },
                        child: const Text('Clear Search'),
                      );
                    } else if (state.selectedCategory != null) {
                      message = 'No products found in "${state.selectedCategory}" category';
                      icon = Icons.category_outlined;
                      action = ElevatedButton(
                        onPressed: () {
                          context.read<ProductBloc>().add(
                            ProductFilterChanged(category: null),
                          );
                        },
                        child: const Text('Show All Categories'),
                      );
                    } else {
                      message = 'No products available';
                      icon = Icons.inventory_2_outlined;
                      action = null;
                    }
                    
                    return EmptyWidget(
                      message: message,
                      icon: icon,
                      action: action,
                    );
                  }

                  return SmartRefresher(
                    controller: _refreshController,
                    onRefresh: () {
                      context.read<ProductBloc>().add(const ProductRefreshRequested());
                      _refreshController.refreshCompleted();
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return BlocBuilder<WishlistBloc, WishlistState>(
                          builder: (context, wishlistState) {
                            bool isInWishlist = false;
                            if (wishlistState is WishlistLoaded) {
                              isInWishlist = wishlistState.wishlistItems
                                  .any((item) => item.product.id == product.id);
                            }

                            return ProductCard(
                              product: product,
                              isInWishlist: isInWishlist,
                              onTap: () {
                                context.go('/product/${product.id}');
                              },
                              onAddToCart: () {
                                context.read<CartBloc>().add(
                                  CartItemAdded(product: product),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.title} added to cart'),
                                    action: SnackBarAction(
                                      label: 'View Cart',
                                      onPressed: () => context.go('/cart'),
                                    ),
                                  ),
                                );
                              },
                              onToggleWishlist: () {
                                context.read<WishlistBloc>().add(
                                  WishlistItemToggled(product: product),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                return const LoadingWidget();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
