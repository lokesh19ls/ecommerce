import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<String> categories;
  final String? selectedCategory;
  final String? selectedSort;
  final bool isSearching;
  final String? searchQuery;

  const ProductLoaded({
    required this.products,
    required this.categories,
    this.selectedCategory,
    this.selectedSort,
    this.isSearching = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
        products,
        categories,
        selectedCategory,
        selectedSort,
        isSearching,
        searchQuery,
      ];

  ProductLoaded copyWith({
    List<Product>? products,
    List<String>? categories,
    String? selectedCategory,
    String? selectedSort,
    bool? isSearching,
    String? searchQuery,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSort: selectedSort ?? this.selectedSort,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProductDetailLoaded extends ProductState {
  final Product product;

  const ProductDetailLoaded({required this.product});

  @override
  List<Object> get props => [product];
}

class ProductError extends ProductState {
  final String message;

  const ProductError({required this.message});

  @override
  List<Object> get props => [message];
}
