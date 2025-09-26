import 'package:equatable/equatable.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';

class CartApiModel extends Equatable {
  final int id;
  final List<CartItemApiModel> products;
  final int total;
  final int discountedTotal;
  final int userId;
  final int totalProducts;
  final int totalQuantity;

  const CartApiModel({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  factory CartApiModel.fromJson(Map<String, dynamic> json) {
    return CartApiModel(
      id: json['id'] as int,
      products: (json['products'] as List<dynamic>)
          .map((item) => CartItemApiModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      discountedTotal: json['discountedTotal'] as int,
      userId: json['userId'] as int,
      totalProducts: json['totalProducts'] as int,
      totalQuantity: json['totalQuantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'products': products.map((item) => item.toJson()).toList(),
      'total': total,
      'discountedTotal': discountedTotal,
      'userId': userId,
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
    };
  }

  Cart toEntity() {
    return Cart(
      id: id,
      products: products.map((item) => item.toEntity()).toList(),
      total: total,
      discountedTotal: discountedTotal,
      userId: userId,
      totalProducts: totalProducts,
      totalQuantity: totalQuantity,
    );
  }

  @override
  List<Object?> get props => [
        id,
        products,
        total,
        discountedTotal,
        userId,
        totalProducts,
        totalQuantity,
      ];
}

class CartItemApiModel extends Equatable {
  final int id;
  final String title;
  final int price;
  final int quantity;
  final int total;
  final double discountPercentage;
  final int discountedPrice;
  final String thumbnail;

  const CartItemApiModel({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedPrice,
    required this.thumbnail,
  });

  factory CartItemApiModel.fromJson(Map<String, dynamic> json) {
    return CartItemApiModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: json['price'] as int,
      quantity: json['quantity'] as int,
      total: json['total'] as int,
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      discountedPrice: json['discountedPrice'] as int,
      thumbnail: json['thumbnail'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'total': total,
      'discountPercentage': discountPercentage,
      'discountedPrice': discountedPrice,
      'thumbnail': thumbnail,
    };
  }

  CartItem toEntity() {
    return CartItem(
      id: id,
      title: title,
      price: price,
      quantity: quantity,
      total: total,
      discountPercentage: discountPercentage,
      discountedPrice: discountedPrice,
      thumbnail: thumbnail,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        price,
        quantity,
        total,
        discountPercentage,
        discountedPrice,
        thumbnail,
      ];
}
