import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/product.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/product/product_card.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
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
        title: Text('Search: "${widget.query}"'),
        actions: [
          IconButton(
            onPressed: () {
              // Show filter options
              _showFilterBottomSheet();
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const LoadingWidget(message: 'Searching products...');
          } else if (state is ProductError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<ProductBloc>().add(
                  ProductSearchRequested(query: widget.query),
                );
              },
            );
          } else if (state is ProductLoaded) {
            final searchResults = state.products
                .where((product) =>
                    product.title.toLowerCase().contains(widget.query.toLowerCase()) ||
                    product.description.toLowerCase().contains(widget.query.toLowerCase()) ||
                    product.category.toLowerCase().contains(widget.query.toLowerCase()))
                .toList();

            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Search Results Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${searchResults.length} results found for "${widget.query}"',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Results Grid
                        Expanded(
                          child: searchResults.isEmpty
                              ? _buildNoResults()
                              : _buildResultsGrid(searchResults),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: ProductCard(
                  product: product,
                  onTap: () {
                    context.go('/product/${product.id}');
                  },
                  onAddToCart: () {
                    // Add to cart functionality
                  },
                  onToggleWishlist: () {
                    // Toggle wishlist functionality
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Price Range
            Text(
              'Price Range',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            RangeSlider(
              values: const RangeValues(0, 1000),
              min: 0,
              max: 1000,
              divisions: 20,
              labels: const RangeLabels('\$0', '\$1000'),
              onChanged: (values) {
                // Handle price range change
              },
            ),
            
            const SizedBox(height: 20),
            
            // Category Filter
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['All', 'Beauty', 'Electronics', 'Fashion', 'Home']
                  .map((category) => FilterChip(
                        label: Text(category),
                        selected: category == 'All',
                        onSelected: (selected) {
                          // Handle category selection
                        },
                      ))
                  .toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Sort Options
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                {'label': 'Relevance', 'value': null},
                {'label': 'Name: A to Z', 'value': 'title'},
                {'label': 'Price: Low to High', 'value': 'price_low'},
                {'label': 'Price: High to Low', 'value': 'price_high'},
                {'label': 'Rating: High to Low', 'value': 'rating'},
                {'label': 'Stock: High to Low', 'value': 'stock'},
                {'label': 'Best Discounts', 'value': 'discount'},
              ].map((sort) => FilterChip(
                        label: Text(sort['label'] as String),
                        selected: sort['value'] == null,
                        onSelected: (selected) {
                          // Handle sort selection
                          if (selected) {
                            // Apply sorting
                            context.read<ProductBloc>().add(
                              ProductLoadRequested(sort: sort['value'] as String?),
                            );
                          }
                        },
                      ))
                  .toList(),
            ),
            
            const SizedBox(height: 30),
            
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Apply filters
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
