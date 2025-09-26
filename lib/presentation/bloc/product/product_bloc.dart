import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({
    required ProductRepository productRepository,
  })  : _productRepository = productRepository,
        super(const ProductInitial()) {
    on<ProductLoadRequested>(_onProductLoadRequested);
    on<ProductRefreshRequested>(_onProductRefreshRequested);
    on<ProductSearchRequested>(_onProductSearchRequested);
    on<ProductDetailRequested>(_onProductDetailRequested);
    on<ProductCategoriesRequested>(_onProductCategoriesRequested);
    on<ProductFilterChanged>(_onProductFilterChanged);
  }

  Future<void> _onProductLoadRequested(
    ProductLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    
    try {
      print('DEBUG: Starting to fetch products...');
      // Determine sort parameters
      String? sortBy;
      String? order;
      
      if (event.sort != null) {
        switch (event.sort!.toLowerCase()) {
          case 'title':
            sortBy = 'title';
            order = 'asc';
            break;
          case 'price_low':
            sortBy = 'price';
            order = 'asc';
            break;
          case 'price_high':
            sortBy = 'price';
            order = 'desc';
            break;
          case 'rating':
            sortBy = 'rating';
            order = 'desc';
            break;
          case 'stock':
            sortBy = 'stock';
            order = 'desc';
            break;
          case 'discount':
            sortBy = 'discountPercentage';
            order = 'desc';
            break;
          default:
            sortBy = 'title';
            order = 'asc';
        }
      }

      final result = await _productRepository.getProducts(
        limit: event.limit,
        skip: 0,
        sortBy: sortBy,
        order: order,
      );
      
      print('DEBUG: Products fetched successfully, count: ${result['products'].length}');
      final products = result['products'] as List<Product>;
      print('DEBUG: Products cast successfully');
      
      // Debug logging for category filtering
      if (event.category != null) {
        final filteredProducts = products.where((product) => 
          product.category.toLowerCase() == event.category!.toLowerCase()).toList();
        print('DEBUG: Filtered products for category "${event.category}": ${filteredProducts.length}');
      } else {
        print('DEBUG: Showing all products (no category filter)');
      }
      
      print('DEBUG: Starting to fetch categories...');
      final categories = await _productRepository.getCategories();
      print('DEBUG: Categories fetched successfully, count: ${categories.length}');
      
      emit(ProductLoaded(
        products: products,
        categories: categories,
        selectedCategory: event.category,
        selectedSort: event.sort,
      ));
      print('DEBUG: ProductLoaded state emitted successfully');
    } on Failure catch (failure) {
      print('DEBUG: Failure caught: ${failure.message}');
      emit(ProductError(message: failure.message));
    } catch (e) {
      print('DEBUG: Unexpected error caught: $e');
      emit(const ProductError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onProductRefreshRequested(
    ProductRefreshRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      
      try {
        // Determine sort parameters
        String? sortBy;
        String? order;
        
        if (currentState.selectedSort != null) {
          switch (currentState.selectedSort!.toLowerCase()) {
            case 'title':
              sortBy = 'title';
              order = 'asc';
              break;
            case 'price_low':
              sortBy = 'price';
              order = 'asc';
              break;
            case 'price_high':
              sortBy = 'price';
              order = 'desc';
              break;
            case 'rating':
              sortBy = 'rating';
              order = 'desc';
              break;
            case 'stock':
              sortBy = 'stock';
              order = 'desc';
              break;
            case 'discount':
              sortBy = 'discountPercentage';
              order = 'desc';
              break;
            default:
              sortBy = 'title';
              order = 'asc';
          }
        }

        final result = await _productRepository.getProducts(
          limit: 20,
          skip: 0,
          sortBy: sortBy,
          order: order,
        );
        
        final products = result['products'] as List<Product>;
        emit(currentState.copyWith(products: products));
      } on Failure catch (failure) {
        emit(ProductError(message: failure.message));
      } catch (e) {
        emit(const ProductError(message: 'An unexpected error occurred'));
      }
    }
  }

  Future<void> _onProductSearchRequested(
    ProductSearchRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const ProductLoadRequested());
      return;
    }

    emit(const ProductLoading());
    
    try {
      final result = await _productRepository.searchProducts(event.query);
      final products = result['products'] as List<Product>;
      
      if (state is ProductLoaded) {
        final currentState = state as ProductLoaded;
        emit(currentState.copyWith(
          products: products,
          isSearching: true,
          searchQuery: event.query,
        ));
      } else {
        final categories = await _productRepository.getCategories();
        emit(ProductLoaded(
          products: products,
          categories: categories,
          isSearching: true,
          searchQuery: event.query,
        ));
      }
    } on Failure catch (failure) {
      emit(ProductError(message: failure.message));
    } catch (e) {
      emit(const ProductError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onProductDetailRequested(
    ProductDetailRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    
    try {
      final product = await _productRepository.getProduct(event.productId);
      emit(ProductDetailLoaded(product: product));
    } on Failure catch (failure) {
      emit(ProductError(message: failure.message));
    } catch (e) {
      emit(const ProductError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onProductCategoriesRequested(
    ProductCategoriesRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final categories = await _productRepository.getCategories();
      
      if (state is ProductLoaded) {
        final currentState = state as ProductLoaded;
        emit(currentState.copyWith(categories: categories));
      } else {
        emit(ProductLoaded(
          products: const [],
          categories: categories,
        ));
      }
    } on Failure catch (failure) {
      emit(ProductError(message: failure.message));
    } catch (e) {
      emit(const ProductError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onProductFilterChanged(
    ProductFilterChanged event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      
      print('DEBUG: ProductFilterChanged - Category: ${event.category}, Sort: ${event.sort}');
      
      // If sort changed, reload products with new sorting
      if (event.sort != null && event.sort != currentState.selectedSort) {
        print('DEBUG: ProductFilterChanged - Sort changed, reloading products...');
        add(ProductLoadRequested(
          limit: 20,
          sort: event.sort,
          category: event.category,
        ));
        return;
      }
      
      // For category changes, just update the state (client-side filtering)
      final newState = currentState.copyWith(
        selectedCategory: event.category,
        selectedSort: event.sort,
      );
      
      print('DEBUG: ProductFilterChanged - Emitting new state...');
      print('DEBUG: ProductFilterChanged - New selectedCategory: ${event.category}');
      print('DEBUG: ProductFilterChanged - New selectedSort: ${event.sort}');
      print('DEBUG: ProductFilterChanged - New state hash: ${newState.hashCode}');
      
      emit(newState);
      
      print('DEBUG: ProductFilterChanged - State emitted successfully');
    }
  }
}
