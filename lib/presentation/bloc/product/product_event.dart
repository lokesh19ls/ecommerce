import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductLoadRequested extends ProductEvent {
  final int? limit;
  final String? sort;
  final String? category;

  const ProductLoadRequested({
    this.limit,
    this.sort,
    this.category,
  });

  @override
  List<Object?> get props => [limit, sort, category];
}

class ProductRefreshRequested extends ProductEvent {
  const ProductRefreshRequested();
}

class ProductSearchRequested extends ProductEvent {
  final String query;

  const ProductSearchRequested({required this.query});

  @override
  List<Object> get props => [query];
}

class ProductDetailRequested extends ProductEvent {
  final int productId;

  const ProductDetailRequested({required this.productId});

  @override
  List<Object> get props => [productId];
}

class ProductCategoriesRequested extends ProductEvent {
  const ProductCategoriesRequested();
}

class ProductFilterChanged extends ProductEvent {
  final String? category;
  final String? sort;

  const ProductFilterChanged({
    this.category,
    this.sort,
  });

  @override
  List<Object?> get props => [category, sort];
}
